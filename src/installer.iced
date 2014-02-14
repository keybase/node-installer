
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
npm = require './npm'
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

  test_gpg : (cb) ->
    gpg = new GPG {}
    log.debug "+ Installer::test_gpg"
    await gpg.test defer err
    if err?
      lines = []
      if (c = @config.get_alt_cmd('gpg'))?
        lines.push """
The GPG command you specified `#{c}` wasn't found; see this page for help installing `gpg`:
"""
      else
        lines.push """
The command `gpg` wasn't found; you need to install it. See this page for more info:
"""
      lines.push """
\t   https://keybase.io/__/command_line/keybase#prerequisites
"""
      err = new Error lines.join("\n")
    log.debug "- Installer::test_gpg -> #{if err? then 'FAILED' else 'OK'}"
    cb err

  #------------

  test_npm : (cb) ->
    cmd = @config.get_cmd('npm')
    log.debug "+ Installer::test_npm"
    await npm.check defer err
    if not err? then #noop
    else if (c = @config.get_alt_cmd('npm'))?
      err = new Error "The npm command you specified `#{c}` wasn't found"
    else 
      err = new Error "Couldn't find an `npm` command in your path"
    log.debug "- Installer::test_npm -> #{if err? then 'FAILED' else 'OK'}"
    cb err

  #------------

  run : (cb) ->
    log.debug "+ Installer::run"
    cb = chain cb, @cleanup.bind(@)
    esc = make_esc cb, "Installer::_run2"
    @config.set_alt_cmds()
    npm.set_config @config
    await @test_gpg           esc defer()
    await @test_npm           esc defer()
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

