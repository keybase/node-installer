
{make_esc} = require 'iced-error'
{keyring} = require 'gpg-wrapper'

##========================================================================

exports.KeyInstall = class KeyInstall

  #-----------------
  
  constructor : (@config, keyset) ->
    @_keyset = keyset

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
    if @_tmp_kerying
      await @_tmp_keyring.nuke defer err
      if err?
        log.warn "Error cleaning up temporary keyring: #{err.message}"
    cb()

  #-----------------

  run2 : (cb) ->
    esc = make_esc cb, "KeyInstall:run2"
    await @make_tmp_keyring esc defer()
    await @temporary_import esc defer()
    await @check_self_sig esc defer()
    await @full_import esc defer()
    cb null

##========================================================================

