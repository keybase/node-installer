
{make_esc} = require 'iced-error'
{a_json_parse} = require('iced-utils').util

##========================================================================

exports.GetIndex = class GetIndex

  constructor : (@config) ->

  #--------------------------

  fetch_index : (cb) ->
    await @config.request "/#{@config.key_version()}/index.asc", defer err, res, @_signed_index
    cb err

  #--------------------------

  decrypt_and_verify : (cb) ->
    esc = make_esc cb, "GetIndex::decrypt_and_verify"
    await @config.make_oneshot_ring 'index', esc defer ring
    await ring.verify_sig { sig : @_signed_index }, esc defer raw
    await a_json_parse raw, esc defer @_index
    console.log @_index
    cb null

  #--------------------------

  run : (cb) -> 
    esc = make_esc cb, "GetIndex::run"
    await @fetch_index esc defer()
    await @decrypt_and_verify esc defer()
    cb null
  
##========================================================================

