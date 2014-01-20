
{keyring} = require 'gpg-wrapper'
{constants} = require './constants'
{log} = require './log'

##========================================================================

exports.SetupKeyRunner = new Class SetupKeyRunner

  constructor : () ->
    @master = keyring.master_ring()
    @id_email = "code@keybase.io"

  #------------

  run : (cb) ->
    await @find_latest_key defer err, key
    unless key?
      await @install_key defer err, key
    cb err

  #------------

  find_latest_key : (cb) ->
    esc = make_esc cb, "SetupKeyRunner::find_latest_key"
    em = constants.uid_email.code
    err = ret = null
    await @master.read_uids_from_key {}, esc defer uids
    comments = (uid.comment for uid in uids when (uid.email is em))
    versions = (parseInt(m[1]) for c in comments when (m = c.match /v(\d+)/))
    if versions.length is 0
      log.warn "No code-signing key (#{em}) in primary GPG keychain"
    else
      max = Math.max versions...
      query = "(#{max}) <#{em}>"
      await @master.find_keys { query }, esc defer out
      msg = if out.length is 0 then "Didn't find any key for query #{query}"
      else if out.length > 1 then "Found too many keys that matched #{query}"
      else null
      if msg? then err = new Error msg
      else ret = ids64[0]
    cb err, ret

  #------------

##========================================================================
