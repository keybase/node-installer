{getopt} = require './getopt'
{fullname,bin,version} = require './package'
{make_esc} = require 'iced-error'
{BaseCommand} = require './base'
{Installer} = require './installer'
{keyring} = require 'gpg-wrapper'
{constants} = require './constants'
keyset = require './keyset'
{json_stringify_sorted} = require('iced-utils').util
log = require './log'

##========================================================================

class VersionCommand extends BaseCommand

  run : (cb) ->
    console.log fullname()
    cb null

##========================================================================

class HelpCommand extends BaseCommand

  constructor : (argv, @err = null) ->
    super argv 

  run : (cb) ->
    console.log """usage: #{bin()} [-vh?] [-C] [-u <url-prefix>] [<keybase-version>]

\tUpgrade or install a version of keybase.  Check signatures for Keybase.io's signing
\tkey. You can provide a specific version or by default you'll get the most recent
\tversion.

Boolean Flags:
\t-v/--version       -- Print the version and quit
\t-h/--help          -- Print the help message and quit
\t-C/--skip-cleanup  -- Don't delete temporary files after install

Options:
\t-u/--url-prefix    -- Specify a URL prefix for fetching (default: #{constants.url_prefix})

Version: #{version()}

"""

    cb @err

##========================================================================

class KeyJsonCommand extends BaseCommand

  run : (cb) ->
    keyset.self_sig = null if @config.argv.get("no-self-sig")
    console.log json_stringify_sorted keyset
    cb null

##========================================================================

class Main

  @OPTS :
    a :
      alias : 'about'
      action : "storeTrue"
      help : 'display version and command name, then quit'

  #-----------

  constructor : ->
    @cmd = null

  #-----------

  parse_args : (cb) ->
    err = null
    flags = [
      "h"
      "v"
      "k"
      "key-json"
      "no-self-sig"
      "help"
      "version"
      "?"
      "skip-cleanup"
      "C"
    ]
    @argv = getopt process.argv[2...], { flags }
    if @argv.get("v", "version")
      @cmd = new VersionCommand()
    else if @argv.get("h", "?", "help")
      @cmd = new HelpCommand()
    else if @argv.get().length > 1
      @cmd = new HelpCommand @argv, (new Error "Usage error: only zero or one argument allowed")
    else if @argv.get("k", "key-json")
      @cmd = new KeyJsonCommand @argv
    else
      @cmd = new Installer @argv
    cb err

  #-----------

  run : (cb) ->
    esc = make_esc cb, "run"
    await @setup    esc defer()
    await @cmd.run  esc defer()
    cb null

  #-----------

  main : () ->
    await @run defer err
    if err? then console.warn err.message
    process.exit if err? then -2 else 0

  #-----------

  setup : (cb) ->
    esc = make_esc cb, "setup"
    await @parse_args esc defer()
    keyring.init { log }
    cb null

##========================================================================

exports.run = run = () -> (new Main).main()

##========================================================================
