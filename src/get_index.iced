
{make_esc} = require 'iced-error'
{chain,unix_time,a_json_parse} = require('iced-utils').util
{constants} = require './constants'


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
    now = unix_time()

    err = if not (t = @_index.timestamp)? then new Error "Bad index; no timestamp"
    else if (a = now - t) > (b = constants.index_timeout) then new Error "Index timed out: #{a} > #{b}"
    else if not @_index.keys?.latest? then new Error "missing required field: keys.latest"
    else if not @_index.package?.latest? then new Error "missing required field: package.latest"
    else null

    cb err

  #--------------------------

  index : () -> @_index

  #--------------------------

  cleanup : (cb) ->
    if @_ring?
      await @_ring.nuke defer err
      log.warn "Error cleaning up 1-shot ring: #{err.message}" if err?
    cb()

  #--------------------------

  run : (cb) -> 
    cb = chain cb, @cleanup.bind(@)
    esc = make_esc cb, "GetIndex::run"
    await @fetch_index esc defer()
    await @decrypt_and_verify esc defer()
    @config.set_index @_index
    cb null
  
##========================================================================

