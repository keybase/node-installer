
{make_esc} = require 'iced-error'
{keyring} = require 'gpg-wrapper'
{fpeq} = require('pgp-utils').util
{hash_json} = require './util'

##========================================================================

exports.KeyUpgrade = class KeyUpgrade

  #-----------------

  constructor : (@config) ->
  
  #-----------------

  run : (cb) ->
    if (a = @config.index().version) > (b = @config.key_version())
      log.info "Key upgrade suggested; new version is #{a}, but we have #{b}"
    cb null

##========================================================================
