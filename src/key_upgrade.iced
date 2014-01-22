
{make_esc} = require 'iced-error'
{keyring} = require 'gpg-wrapper'
{fpeq} = require('pgp-utils').util
{clean_ring} = require './util'
{chain} = require('iced-utils').util

##========================================================================

exports.KeyUpgrade = class KeyUpgrade

  #-----------------

  constructor : (@config) ->
    @_v = {}
  
  #-----------------

  fetch : (cb) ->
    await @config.request "/#{@_v.old}/keyset-#{@_v.new}.asc", defer err, res, @_sig
    cb err

  #-----------------

  decrypt_and_verify : (cb) ->
    args = { which : 'code', sig : @_sig }
    await @config.oneshot_verify args, defer err, @_keyset, @_ring
    cb null

  #-----------------

  install : (cb) -> (new KeyInstall @config, @_keyset).run cb

  #-----------------

  run : (cb) ->
    esc = make_esc cb, "KeyUpgrade::run"
    cb = chain cb, clean_ring.bind(null, @_ring)
    if (@_v.new = @config.index().version) > (@_v.old = @config.key_version())
      log.info "Key upgrade suggested; new version is #{@_v.new}, but we have #{@_v.old}"
      await @fetch defer()
      await @decrypt_and_verify esc defer() 
      await @install esc defer()
    cb null

##========================================================================
