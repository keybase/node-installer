
{make_esc} = require 'iced-error'

##========================================================================

exports.GetIndex = class GetIndex

  constructor : (@config) ->

  #--------------------------

  decrypt_and_verify : (cb) -> cb null

  #--------------------------

  fetch_index : (cb) ->
    await @config.request "/#{@config.key_version()}/index.asc", defer err, res, @_signed_index
    cb err

  #--------------------------

  run : (cb) -> 
    esc = make_esc cb, "GetIndex::run"
    await @fetch_index esc defer()
    await @decrypt_and_verify esc defer()
    cb null

  #--------------------------
  
##========================================================================

