
{make_esc} = require 'iced-error'
{npm} = require './npm'
path = require 'path'
fs = require 'fs'
log = require './log'
{constants} = require './constants'
{createHash} = require 'crypto'

##========================================================================

class FileBundle 

  #-----
  
  constructor : (@uri, @body) ->
  filename : () -> path.basename(@uri.path)
  fullpath : () -> @_fullpath
  version : () -> 
    parts = @filename().splt(/-/)
    parts = parts[1].split(/\./)[0...-1]
    parts.join(".")

  #-----

  hash : () -> createHash('SHA512').update(@body).digest('hex')

  #-----

  write : (dir, encoding, cb) ->
    p = @_fullpath = path.join(dir, @filename())
    await fs.writeFile p, @body, { mode : 0o400, encoding }, defer err
    cb err

##========================================================================

exports.SoftwareUpgrade = class SoftwareUpgrade

  #-------------------------

  constructor : (@config) ->

  #-------------------------

  fetch : (file,cb) ->
    await @config.request file, defer err, req, body
    ret = new FileBundle req.request.uri, body unless err?
    cb err, ret

  #-------------------------

  fetch_package : (cb) ->
    file = [ "pkg", (@config.argv.get()?[0] or constants.links.stable)].join('/')
    await @fetch file, defer err, @package
    cb err

  #-------------------------

  fetch_signature : (cb) ->
    file = "/sig/files/#{@config.key_version()}/#{@package.filename()}.asc"
    await @fetch file, defer err, @signature
    cb err

  #-------------------------

  write_files : (cb) ->
    esc = make_esc cb, "SoftwareUpgrade::write_files"
    tmpdir = @config.get_tmpdir()
    await @package.write tmpdir, 'binary', esc defer()
    await @signature.write tmpdir, 'utf8', esc defer()
    cb null

  #-------------------------

  verify_signature : (cb) ->
    args = 
      which : 'code'
      sig : @signature.fullpath()
      file : @package.fullpath()
    await @config.oneshot_verify args, defer err
    cb err

  #-------------------------

  verify_hash : (cb) ->
    h1 = @pacakge.hash()
    h2 = @config.index_lookup_hash @package.version()
    err = null
    if h1 isnt h2
      err = new Error "Hash mismatch on #{@package.filename()}: #{h1} != #{h2}"
    cb err

  #-------------------------
  
  install_package : (cb) ->
    p = @package.fullpath()
    log.debug "| Full name for install: #{p}"
    log.info "Running npm install #{@package.filename()}: this may take a minute, please be patient"
    args = [ "install" ,  "-g", p ]
    await npm { args }, defer err
    cb err

  #-------------------------

  run : (cb) ->
    esc = make_esc cb, "SoftwareUpgrade::run"
    await @fetch_package esc defer()
    await @fetch_signature esc defer()
    await @write_files esc defer()
    await @verify_hash esc defer()
    await @verify_signature esc defer()
    await @install_package esc defer()
    cb null

##========================================================================

