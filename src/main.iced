{getopt} = require 'iced-utils'
{fullname,bin,version} = require './package'
{make_esc} = require 'iced-error'
{BaseCommand} = require './base'
{Installer} = require './installer'
{keyring} = require 'gpg-wrapper'
{constants} = require './constants'
{hash_json} = require './util'
keyset = require '../json/keyset'
log = require './log'
os = require 'os'
path = require 'path'

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
\t-k/--key-json      -- Output the hash of the JSON file corresponding to the built-in keyset
\t-S/--no-https      -- Don't use HTTP. This should be safe since we check PGP sigs on everything.

Options:
\t-u/--url-prefix    -- Specify a URL prefix for fetching (default: #{constants.url_prefix})
\t-c/--cmd           -- Use a command other than `gpg`, which is the default

Version: #{version()}

"""

    cb @err

##========================================================================

class KeyJsonCommand extends BaseCommand

  run : (cb) ->
    keyset.self_sig = null
    process.stdout.write hash_json keyset
    cb null

##========================================================================

class Main

  #-----------

  constructor : ->
    @cmd = null

  #-----------

  parse_args : (cb) ->
    err = null
    flags = [
      "d"
      "h"
      "v"
      "k"
      "C"
      "?"
      "S"
      "debug"
      "key-json"
      "hash"
      "help"
      "version"
      "skip-cleanup"
      "no-https"
    ]
    @argv = getopt process.argv[2...], { flags }
    if @argv.get("v", "version")
      @cmd = new VersionCommand()
    else if @argv.get("h", "?", "help")
      @cmd = new HelpCommand()
    else if @argv.get("k", "key-json")
      @cmd = new KeyJsonCommand @argv
    else if @argv.get().length > 1
      @cmd = new HelpCommand @argv, (new Error "Usage error: only zero or one argument allowed")
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
    if err? then log.error err.message
    process.exit if err? then -2 else 0

  #-----------

  setup_logger : () ->
    p = log.package()
    p.env().set_level p.DEBUG if @argv.get("d", "debug")

  #-----------

  setup : (cb) ->
    esc = make_esc cb, "setup"
    await @parse_args esc defer()
    @setup_logger()
    cb null

##========================================================================

exports.run = run = () -> (new Main).main()

##========================================================================
