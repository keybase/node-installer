
{BaseCommand} = require './base'
{keyring,BufferOutStream,GPG} = require 'gpg-wrapper'
{make_esc} = require 'iced-error'
request = require './request'
{fullname} = require './package'
{constants} = require './constants'
{KeySetup} = require './key_setup'
{KeyUpgrade} = require './key_upgrade'
{GetIndex} = require './get_index'
{SoftwareUpgrade} = require './software_upgrade'
log = require './log'
{chain} = require('iced-utils').util

##========================================================================

exports.Installer = class Installer extends BaseCommand

  constructor : (argv) ->
    super argv

  #------------

  cleanup : (cb) ->
    await @config.cleanup defer e2
    log.error "In cleanup: #{e2}" if e2?
    if not err? and @package?
      log.info "Succesful install: #{@package.filename()}"
    cb()

  #------------

  run : (cb) ->
    log.debug "+ Installer::run"
    cb = chain cb, @cleanup.bind(@)
    esc = make_esc cb, "Installer::_run2"
    await @config.make_tmpdir esc defer()
    await @setup_keyring      esc defer()
    await @key_setup          esc defer()
    await @get_index          esc defer()
    await @key_upgrade        esc defer()
    await @software_upgrade   esc defer()
    log.debug "- Installer::run"
    cb null

  #------------

  key_setup        : (cb) -> (new KeySetup @config).run cb
  get_index        : (cb) -> (new GetIndex @config).run cb
  key_upgrade      : (cb) -> (new KeyUpgrade @config).run cb
  software_upgrade : (cb) -> (new SoftwareUpgrade @config).run cb

  #------------

  setup_keyring : (cb) ->
    keyring.init {
      log : log,
      get_tmp_keyring_dir : () => @config.get_tmpdir()
    }
    @config.set_master_ring()
    cb null

##========================================================================

