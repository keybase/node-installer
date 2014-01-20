
{keyring} = require 'gpg-wrapper'
{constants} = require './constants'
{log} = require './log'
{make_esc} = require 'iced-error'

##========================================================================

exports.SetupKeyRunner = new Class SetupKeyRunner

  constructor : () ->
    @master = keyring.master_ring()
    @id_email = "code@keybase.io"
    @_key = null

  #------------

  run : (cb) ->
    esc = make_esc cb, "SetupKeyRunner::run"
    await @find_latest_key esc defer()
    await @install_key esc defer() unless @_key?
    cb err

  #------------

  find_latest_key : (cb) ->
    esc = make_esc cb, "SetupKeyRunner::find_latest_key"
    em = constants.uid_email.code
    err = null
    await @master.read_uids_from_key {}, esc defer uids
    comments = (uid.comment for uid in uids when (uid.email is em))
    versions = (parseInt(m[1]) for c in comments when (m = c.match /v(\d+)/))
    if versions.length is 0
      log.warn "No code-signing key (#{em}) in primary GPG keychain"
    else
      max = Math.max versions...
      query = "(#{max}) <#{em}>"
      await @master.find_keys { query }, esc defer out
      if out.length is 0     then err = new Error "Didn't find any key for query #{query}"
      else if out.length > 1 then err = new Error "Found too many keys that matched #{query}"
      else
        @_key = @master.make_key { key_id_64 : ids64[0], username : em }
        await @_key.load defer err
        @_key = null if err
    cb err

  #------------

##========================================================================
