
{make_esc} = require 'iced-error'
{keyring} = require 'gpg-wrapper'
{json_stringify_sorted} = require('iced-utils').util

##========================================================================

exports.KeyInstall = class KeyInstall

  #-----------------
  
  constructor : (@config, keyset) ->
    @_keyset = keyset
    @_tmp_keyring = null
    @_keys = {}

  #-----------------

  run : (cb) ->
    esc = make_esc cb, "KeyInstall::run"
    await @run2 defer err
    await @cleanup defer()
    cb err

  #-----------------

  make_tmp_keyring : (cb) ->
    await keyring.TmpKeyRing.make defer err, @_tmp_kerying
    cb err

  #-----------------

  cleanup : (cb) ->
    if @_tmp_keyring?
      await @_tmp_keyring.nuke defer err
      if err?
        log.warn "Error cleaning up temporary keyring: #{err.message}"
    cb()

  #-----------------

  temporary_import : (cb) ->
    esc = make_esc cb, "KeyInstaller::temporary_import"
    @_keys.code = k = @_tmp_keyring.make_key @_keyset.keys.code

    await k.save esc defer err
    await @_tmp_keyring.list_fingerprints esc defer fps

    msg = if fps.length is 0 then "key save failed; no fingerprints"
    else if fps.length > 1 then "keyring corruption; too many fingerprints found"
    else if not fpeq((a = fps[0]), (b =@_keyset.keys.code.fingerprint))
      "fingerprint mismatch after import: #{a} != #{b}"

    err = if msg? then new Error(msg) else null
    cb err

  #-----------------

  check_self_sig : (cb) ->
    sig = @_keyset.self_sig
    @_keyset.self_sig = null
    payload = json_stringify_sorted @_keyset
    await @_keys.verify_sig { which : "self sig on keyset", payload, sig }, defer err
    cb err

  #-----------------

  full_import : (cb) ->
    esc = make_esc cb, "KeyInstall::full_import"
    master = keyring.master_ring()
    @_keys.index = k = keyring.master_ring().make_key @_keyset.keys.index
    await k.commit null, esc defer()
    await master.commit null, esc defer()
    cb null

  #-----------------

  run2 : (cb) ->
    esc = make_esc cb, "KeyInstall:run2"
    await @make_tmp_keyring esc defer()
    await @temporary_import esc defer()
    await @check_self_sig esc defer()
    await @full_import esc defer()
    cb null

##========================================================================

