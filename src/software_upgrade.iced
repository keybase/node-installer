
{make_esc} = require 'iced-error'
{npm} = require './npm'

##========================================================================

class FileBundle 

  #-----
  
  constructor : (@uri, @body) ->
  filename : () -> path.basename(@uri.path)
  fullpath : () -> @_fullpath

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
    await @config.request file, defer err, res, body
    ret = new FileBundle req.request.uri, body unless err?
    cb err, ret

  #-------------------------

  fetch_package : (cb) ->
    file = @config.argv.get()?[0] or "latest-stable"
    await @fetch file, defer err, @package
    cb err

  #-------------------------

  fetch_signature : (cb) ->
    file = "/#{@config.key_version()}/#{@package.filename()}.asc"
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

  install_package : (cb) ->
    p = @package.filename()
    log.info "Running npm install #{p}: this may take a minute, please be patient"
    args = [ "install" ,  "-g", p ]
    await npm { args }, defer err
    cb err

  #-------------------------

  run : (cb) ->
    esc = make_esc cb, "SoftwareUpgrade::run"
    await @fetch_package esc defer()
    await @fetch_signature esc defer()
    await @write_files esc defer()
    await @verify_signature esc defer()
    await @install_package esc defer()
    cb null

##========================================================================

