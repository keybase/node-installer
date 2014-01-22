
{make_esc} = require 'iced-error'

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
    file = @argv.get()?[0] or "latest-stable"
    await @fetch file, defer err, @package
    cb err

  #-------------------------

  fetch_signature : (cb) ->
    file = "/#{@config.key_version()}/#{@package.filename()}.asc"
    await @fetch file, defer err, @fetch_signature
    cb err

  #-------------------------

  run : (cb) ->
    esc = make_esc cb, "SoftwareUpgrade::run"
    await @fetch_package esc defer()
    await @fetch_signature esc defer()
    await @verify_signature esc defer()
    await @install_package esc defer()
    cb null

##========================================================================

