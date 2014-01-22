
{BaseCommand} = require './base'
{keyring,BufferOutStream,GPG} = require 'gpg-wrapper'
{make_esc} = require 'iced-error'
{signer_id_email,key,id64} = require './key'
request = require './request'
{fullname} = require './package'
{constants} = require './constants'
{npm} = require './npm'
path = require 'path'
fs = require 'fs'
{KeySetup} = require './key_setup'
{KeyUpgrade} = require './key_upgrade'
{GetIndex} = require './get_index'
log = require './log'
{chain} = require('iced-utils').util

##========================================================================

class FileBundle 
  constructor : (@uri, @body) ->
  filename : () -> path.basename(@uri.path)
  fullpath : () -> @_fullpath

  write : (dir, encoding, cb) ->
    p = @_fullpath = path.join(dir, @filename())
    await fs.writeFile p, @body, { mode : 0o400, encoding }, defer err
    cb err

##========================================================================

exports.Installer = class Installer extends BaseCommand

  constructor : (argv) ->
    super argv

  #------------

  write_files : (cb) ->
    esc = make_esc cb, "Installer::write_files"
    await @make_tmpdir esc defer()
    await @package.write @tmpdir, 'binary', esc defer()
    await @signature.write @tmpdir, 'utf8', esc defer()
    cb null
  
  #------------

  import_key : (cb) ->
    esc = make_esc cb, "Installer::import_key"
    keybuf = new Buffer key, 'utf8'
    args = [ "--import" ]
    await @gpg.run { args, stdin : keybuf, quiet : true }, esc defer out
    await @gpg.assert_exactly_one id64, esc defer()
    cb null

  #------------

  request : (url, cb) ->
    await request opts, defer err, res, body
    cb err, res, body

  #------------

  fetch_package : (cb) ->
    err = null
    prefix = @argv.get("url-prefix", "u") or constants.url_prefix
    file = @argv.get()?[0] or "latest-stable"
    url = url_join(prefix, file)

    # Need encoding : null to get a buffer object back from 
    # request, and not something fishy like a UTF-8 converted string
    console.log "Fetching archive: #{url}"
    await @request url, defer err, res, body
    if err?
      err = new Error "Error in fetch: #{err.message}"
    else if (sc = res.statusCode) isnt 200
      err = new Error "bad status code in fetch: #{sc}"
    else
      @package = new FileBundle res.request.uri, body
    cb err

  #------------

  fetch_signature : (cb) ->
    err = null
    url = @package.uri.format() + ".asc"
    console.log "Fetching signature: #{url}"
    await @request url, defer err, res, body
    if err?
      err = new Error "Error in fetch: #{err.message}"
    else if (sc = res.statusCode) isnt 200
      err = new Error "bad status code in fetch: #{sc}"
    else
      @signature = new FileBundle res.request.uri, body
    cb err

  #------------

  verify_signature : (cb) ->

    count_lines = (lines, regex) ->
      n = 0
      (n++ for line in lines when line.match(regex))
      return n

    find = (lines, regex, m1) -> 
      (return true for line in lines when (m = line.match(regex)) and (m[1] is m1))
      return false

    args = [ 
      "--verify", "--keyid-format", "long", 
      @signature.fullpath(), @package.fullpath() 
    ]
    stderr = new BufferOutStream()
    await @gpg.run { args, stderr }, defer err, out
    unless err?
      data = stderr.data().toString('utf8').split("\n")
      if (count_lines(data, /Signature made/) isnt 1) or
           (count_lines(data, /using RSA key/) isnt 1) or
           (count_lines(data, /Good signature from/) isnt 1)
        err = new Error "Wrong number of signatures; expected exactly 1"
      else if not find(data, /using RSA key ([A-F0-9]{16})/, id64)
        err = new Error "Didn't get a signature with key ID #{id64}"
      else if not find(data, /Good signature from.*<(\S+)>/, signer_id_email)
        err = new Error "Didn't get a signature from email=#{signer_id_email}"
    unless err?
      args = [ "--list-packets" ]
      await @gpg.run { args, stdin : @signature.body }, defer err, out
      if not err? and not (find(out.toString('utf8').split("\n"), /:signature packet: algo 1, keyid ([A-F0-9]{16})/, id64))
        err = new Error "Bad signature; didn't match key ID=#{id64}"
    console.log "Verified package with Keybase.io's code-signing key"
    cb err

  #------------

  install_package : (cb) ->
    console.log "Running npm install #{@package.filename()}; this may take a minute, please be patient"
    args = [ "install" ,  "-g", @package.fullpath() ]
    await npm { args }, defer err
    cb err

  #------------

  cleanup : (cb) ->
    await @config.cleanup defer e2
    log.error "In cleanup: #{e2}" if e2?
    if not err? and @package?
      log.info "Succesful install: #{@package.filename()}"
    cb()

  #------------

  run : (cb) ->
    log.debug "+ Installer::run"
    cb = chain cb, @cleanup.bind(@)
    esc = make_esc cb, "Installer::_run2"
    await @config.make_tmpdir esc defer()
    await @setup_keyring      esc defer()
    await @key_setup          esc defer()
    await @get_index          esc defer()
    await @key_upgrade        esc defer()
    await @software_upgrade   esc defer()
    log.debug "- Installer::run"
    cb null

  #------------

  setup_key        : (cb) -> (new KeySetup @config).run cb
  get_index        : (cb) -> (new GetIndex @config).run cb
  upgrade_key      : (cb) -> (new KeyUpgrade @config).run cb
  upgrade_software : (cb) -> (new SoftwareUpgrade @config).run cb

  #------------

  setup_keyring : (cb) ->
    keyring.init {
      log : log,
      get_tmp_keyring_dir : () => @config.get_tmpdir()
    }
    cb null

##========================================================================

