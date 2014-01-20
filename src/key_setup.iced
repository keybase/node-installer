
{keyring} = require 'gpg-wrapper'
{constants} = require './constants'
{log} = require './log'
{make_esc} = require 'iced-error'
{request} = require './request'
key = require './key'
{fpeq} = require('pgp-utils').util
{athrow,a_json_parse} = require('iced-utils').util

##========================================================================

exports.KeySetup = class KeySetup

  constructor : (@config) ->
    @master = keyring.master_ring()
    @_key = null

  #------------

  key : () -> @_key

  #------------

  check_prepackaged_key : (cb) ->
    v = key.version
    await request @config.make_url("/#{v}/key.json"), esc defer res, body
    await a_json_parse body, esc defer json

    err = if (a = json?.version) isnt v
      new Error "Version mismatch; expected #{v} but got #{a}"
    else if not (a = json?.code?.id160)? or not(fpeq(a, key.code.id160))
      new Error "Fingerprint mismatch; expected #{a} but got #{b}"
    else null

    cb err

  #------------

  install_prepackaged_key : (cb) ->
    ik = new InstallKey @config, key
    await ik.run esc defer err
    cb err

  #------------

  run : (cb) ->
    esc = make_esc cb, "SetupKeyRunner::run"
    await @find_latest_key esc defer()
    unless @_key?
      await @check_prepackaged_key   esc defer()
      await @install_prepackaged_key esc defer()
    cb err

  #------------

  find_latest_key : (cb) ->
    esc = make_esc cb, "SetupKeyRunner::find_latest_key"
    em = constants.uid_email.code
    err = null
    await @master.read_uids_from_key {}, esc defer uids
    comments = (uid.comment for uid in uids when (uid.email is em))
    versions = (parseInt(m[1]) for c in comments when (m = c.match /^v(\d+)$/))
    if versions.length is 0
      log.warn "No code-signing key (#{em}) in primary GPG keychain"
    else
      max = Math.max versions...
      query = "(v#{max}) <#{em}>"
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
