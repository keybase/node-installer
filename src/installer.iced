
{BaseCommand} = require './base'
{BufferOutStream,assert_exactly_one,gpg} = require 'gpg-wrapper'
{make_esc} = require 'iced-error'
{signer_id_email,key,id32,id64} = require './key'
request = require 'request'
{fullname} = require './package'
{constants} = require './constants'
{tmpdir} = require 'os'
{rng} = require 'crypto'
{npm} = require './npm'
path = require 'path'
fs = require 'fs'

##========================================================================

url_join = (args...) ->
  parts = [ args[0] ]
  for arg in args[1...]
    if parts[-1...][0][-1...][0] isnt '/' then parts.push '/'
    parts.push arg
  parts.join ''

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
    @headers = { "X-Keybase-Installer" : fullname() }
    super argv

  #------------

  make_tempdir : (cb) ->
    r = rng(10).toString("hex")
    @tmpdir = path.join(tmpdir(), "keybase_install_#{r}");
    await fs.mkdir @tmpdir, 0o700, defer err
    console.log "Made temporary directory: #{@tmpdir}"
    cb err

  #------------

  write_files : (cb) ->
    esc = make_esc cb, "Installer::write_files"
    await @make_tempdir esc defer()
    await @package.write @tmpdir, 'binary', esc defer()
    await @signature.write @tmpdir, 'utf8', esc defer()
    cb null
  
  #------------

  import_key : (cb) ->
    esc = make_esc cb, "Installer::import_key"
    keybuf = new Buffer key, 'utf8'
    args = [ "--import" ]
    await gpg { args, stdin : keybuf, quiet : true }, esc defer out
    await assert_exactly_one id32, esc defer()
    cb null

  #------------

  request : (url, cb) ->
    opts = { url, @headers, encoding : null }
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

    args = [ "--verify", @signature.fullpath(), @package.fullpath() ]
    stderr = new BufferOutStream()
    await gpg { args, stderr }, defer err, out
    unless err?
      data = stderr.data().toString('utf8').split("\n")
      if (count_lines(data, /Signature made.*using.*key.*ID/) isnt 1) or
           (count_lines(data, /Good signature from/) isnt 1)
        err = new Error "Wrong number of signatures; expected exactly 1"
      else if not find(data, /Signature made.*using RSA key ID ([A-F0-9]{8})/, id32)
        err = new Error "Didn't get a signature with short_id #{short_id}"
      else if not find(data, /Good signature from.*<(\S+)>/, signer_id_email)
        err = new Error "Didn't get a signature from email=#{signer_id_email}"
    unless err?
      args = [ "--list-packets" ]
      await gpg { args, stdin : @signature.body }, defer err, out
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

  run2 : (cb) ->
    esc = make_esc cb, "Installer::run"  
    await @verify_signature esc defer()
    await @install_package esc defer()
    cb null
  
  #------------

  cleanup : (cb) ->
    esc = make_esc cb, "Installer::cleanup"
    await fs.readdir @tmpdir, esc defer files
    for f in files
      p = path.join @tmpdir, f
      await fs.unlink p, esc defer()
    await fs.rmdir @tmpdir, esc defer()
    cb null

  #------------

  run : (cb) ->
    esc = make_esc cb, "Installer::run"
    await @import_key      esc defer()
    await @fetch_package   esc defer()
    await @fetch_signature esc defer()
    await @write_files     esc defer()

    await @run2 defer err
    if not err? and not @argv.get("C", "skip-cleanup")
      await @cleanup defer e2
      console.warn "In cleanup: #{e2}" if e2?
    unless err?
      console.log "Succesful install: #{@package.filename()}"
    cb err

##========================================================================

