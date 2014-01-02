
{BaseCommand} = require './base'
{assert_exactly_one,gpg} = require 'gpg-wrapper'
{make_esc} = require 'iced-error'
{key,short_id} = require './key'
request = require 'request'
{fullname} = require './package'
{constants} = require './constants'
{tmpdir} = require 'os'
{rng} = require 'crypto'
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

  write : (dir, encoding, cb) ->
    p = path.join(dir, @filename())
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
    await assert_exactly_one short_id, esc defer()
    cb null

  #------------

  fetch_package : (cb) ->
    err = null
    prefix = @argv.get("url-prefix", "u") or constants.url_prefix
    file = @argv.get()?[0] or "latest-stable"
    url = url_join(prefix, file)
    opts =  { url, @headers }
    console.log "Fetching archive: #{url}"
    await request opts, defer err, res, body
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
    await request { url, @headers }, defer err, res, body
    if err?
      err = new Error "Error in fetch: #{err.message}"
    else if (sc = res.statusCode) isnt 200
      err = new Error "bad status code in fetch: #{sc}"
    else
      @signature = new FileBundle res.request.uri, body
    cb err

  #------------

  verify_signature : (cb) ->
    cb null

  #------------

  install_package : (cb) ->
    cb null

  #------------

  run2 : (cb) ->
    esc = make_esc cb, "Installer::run"  
    await @verify_signature esc defer()
    await @install_package esc defer()
    cb null
  
  #------------

  cleanup : (cb) ->
    cb null

  #------------

  run : (cb) ->
    esc = make_esc cb, "Installer::run"
    await @import_key      esc defer()
    await @fetch_package   esc defer()
    await @fetch_signature esc defer()
    await @write_files     esc defer()

    await @run2 defer err
    await @cleanup defer()

    cb err

##========================================================================

