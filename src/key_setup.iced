
{keyring} = require 'gpg-wrapper'
{constants} = require './constants'
log = require './log'
{make_esc} = require 'iced-error'
keyset = require '../json/keyset'
{fpeq} = require('pgp-utils').util
{athrow,a_json_parse} = require('iced-utils').util
{KeyInstall} = require './key_install'
{key_query} = require './util'

##========================================================================

exports.KeySetup = class KeySetup

  constructor : (@config) ->
    @_key = null

  #------------

  key : () -> @_key

  #------------

  check_prepackaged_key : (cb) ->
    esc = make_esc cb, "KeySetup::check_prepackaged_key"
    v = keyset.version
    await @config.request "/sig/files/#{v}/keyset.json", esc defer res, body
    await a_json_parse body, esc defer json

    err = if (a = json?.version) isnt v
      new Error "Version mismatch; expected #{v} but got #{a}"
    else if not (a = json?.keys.code?.fingerprint)? 
      console.log json
      new Error "Fingerprint failure; none found in server version"
    else if not(fpeq(a, (b = keyset.keys.code.fingerprint)))
      new Error "Fingerprint mismatch; expected #{a} but got #{b}"
    else null

    cb err

  #------------

  install_prepackaged_key : (cb) ->
    log.debug "+ Installing prepackaged key: v#{keyset.version}"
    ki = new KeyInstall @config, keyset
    await ki.run defer err
    log.debug "- Installed: -> #{err}"
    cb err

  #------------

  run : (cb) ->
    esc = make_esc cb, "SetupKeyRunner::run"
    await @find_latest_key 'index', esc defer index_key
    await @find_latest_key 'code' , esc defer @_key, version
    unless index_key? and @_key?
      await @check_prepackaged_key   esc defer()
      await @install_prepackaged_key esc defer()
      @config.set_key_version keyset.version
    cb null

  #------------

  find_latest_key : (which, cb) ->
    esc = make_esc cb, "SetupKeyRunner::find_latest_key"
    em = constants.uid_email[which]
    err = key = null
    master = @config.master_ring()
    await master.read_uids_from_key {}, esc defer uids
    comments = (uid.comment for uid in uids when (uid? and (uid.email is em)))
    versions = (parseInt(m[1]) for c in comments when (m = c.match /^v(\d+)$/))
    if versions.length is 0
      log.warn "No #{which}-signing key (#{em}) in primary GPG keychain"
    else
      max = Math.max versions...
      query = key_query max, which
      await master.find_keys { query }, esc defer out
      if out.length is 0     then err = new Error "Didn't find any key for query #{query}"
      else if out.length > 1 then err = new Error "Found too many keys that matched #{query}"
      else
        key = master.make_key { key_id_64 : out[0], username : em }
        await key.load defer err
        key = null if err
        @config.set_key_version max

    cb err, key, max

  #------------

##========================================================================
