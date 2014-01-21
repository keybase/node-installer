
{make_esc} = require 'iced-error'
{a_json_parse} = require('iced-utils').util

chain = (cb2, cb1) -> (args...) -> cb1 () -> cb2 args...

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
    await @config.make_oneshot_ring 'index', esc defer @_ring
    await @_ring.verify_sig { sig : @_signed_index }, esc defer raw
    await a_json_parse raw, esc defer @_index
    console.log @_index
    cb null

  #--------------------------

  cleanup : (cb) ->
    if @_ring?
      await @_ring.nuke defer err
      log.warn "Error cleaning up 1-shot ring: #{err.message}" if err?
    cb()

  #--------------------------

  run : (cb) -> 
    cb = chain cb, (cb2) => @cleanup cb2
    esc = make_esc cb, "GetIndex::run"
    await @fetch_index esc defer()
    await @decrypt_and_verify esc defer()
    cb null
  
##========================================================================

