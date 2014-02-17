{keyring} = require 'gpg-wrapper'
{constants} = require './constants'
log = require './log'
{make_esc} = require 'iced-error'
keyset = require '../json/keyset'
{fpeq} = require('pgp-utils').util
{athrow,a_json_parse} = require('iced-utils').util
{KeyInstall} = require './key_install'

##========================================================================

exports.KeySetup = class KeySetup

  constructor : (@config) ->

  #------------

  check_prepackaged_keyset : (cb) ->
    esc = make_esc cb, "KeySetup::check_prepackaged_keyset"
    v = keyset.version
    log.debug "+ KeySetup::check_prepackaged_key #{v}"
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

    log.debug "- KeySetup::check_prepackaged_keyset #{v} -> #{err}"
    cb err

  #------------

  install_prepackaged_keyset : (cb) ->
    log.debug "+ Installing prepackaged keyset: v#{keyset.version}"
    ki = new KeyInstall @config, keyset
    await ki.run defer err
    keys = ki.keys()
    keys.version = keyset.version
    @config.set_keys keys
    log.debug "- Installed: -> #{err}"
    cb err

  #------------

  find_keyset : (cb) ->
    log.debug "+ KeySetup::find_keyset"
    esc = make_esc cb, "SetupKeyRunner::find_keyset"
    keys = {}
    found = false
    await @find_key { which : 'code' }, esc defer keys.code, v
    if keys.code?
      await @find_key { which : 'index', version : v }, esc defer keys.index
      if keys.index?
        keys.version = v
        @config.set_keys keys
        found = true
    log.debug "- KeySetup::find_both_keys #{found} #{if v? then '@ version ' + v else ''}"
    cb null, found, keys

  #------------

  run : (cb) ->
    log.debug "+ KeySetup::run"
    esc = make_esc cb, "SetupKeyRunner::run"
    await @find_keyset esc defer found
    unless found
      await @check_prepackaged_keyset   esc defer()
      await @install_prepackaged_keyset esc defer()
    log.debug "- KeySetup::run (found=#{found})"
    cb null

  #------------

  find_key : ({which, version}, cb) ->
    log.debug "+ KeySetup::find_latest_key '#{which}'"
    em = constants.uid_email[which]
    err = key = null
    all_keys = @config.keyring_index().lookup().email.get(em)

    # Go through all of the relevant keys, and all of their
    # different UIDs.  Find either the version given, or the
    # one with maximum version ID
    wanted_key = null
    wanted_v = null
    for key in all_keys
      for uid in key.userids() when (m = uid.comment?.match /^v(\d+)$/ )
        v = parseInt(m[1],10)
        if version? and (v is version)
          wanted_key = key
          wanted_v = v
          break
        else if not wanted_v? or v > wanted_v
          wanted_key = key
          wanted_v = v
      if version? and wanted_key then break

    if not wanted_key?
      log.warn "No #{which}-signing key (#{em}) in primary GPG keychain (@ version #{wanted_v})"
    else
      key = @config.master_ring().make_key { 
        fingerprint : wanted_key.fingerprint(), 
        username : wanted_key.emails()[0]
      }
      await key.load defer err
      if err? then key = null

    log.debug "- KeySetup::find_latest_key '#{which}' -> #{err} / #{wanted_v}"
    cb err, key, wanted_v

  #------------

##========================================================================
