
{make_esc} = require 'iced-error'
{keyring} = require 'gpg-wrapper'
{fpeq} = require('pgp-utils').util
{hash_json} = require './util'

##========================================================================

exports.KeyUpgrade = class KeyUpgrade

  #-----------------

  constructor : (@config) ->
  
  #-----------------

  run : (cb) -> cb null

##========================================================================
