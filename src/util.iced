
{json_stringify_sorted} = require('iced-utils').util
{createHash} = require 'crypto'
{constants} = require './constants'

#===========================================================================

exports.hash_json = (x) -> 
  createHash('SHA512').update(json_stringify_sorted(x)).digest('hex')

#===========================================================================

exports.key_query = (v, which) -> 
  "(v#{v}) <#{which}@#{constants.canonical_host}>"

#===========================================================================

exports.clean_ring = (ring, cb) ->
  if ring?
    await ring.nuke defer err
    log.warn "Error cleaning up 1-shot ring: #{err.message}" if err?
  cb()

#===========================================================================

