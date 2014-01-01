{getopt} = require './getopt'
package_json = require '../package.json'
{make_esc} = require 'iced-error'
gpg = require 'gpg-wrapper'

##========================================================================

find_bin = () ->
  for k,v of package_json.bin
    return k

##========================================================================

exports.BaseCommand = class BaseCommand

  constructor : (@argv) ->

##========================================================================

class AboutCommand extends BaseCommand

  run : (cb) ->
    console.log "#{find_bin()} v#{package_json.version}"
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
    @argv = getopt @process.argv[2...], { flags : "hv?", opts : "" }

  #-----------

  arg_parse_init : () ->

    @ap = new ArgumentParser
      addHelp : true
      version : package_json.version
      description : "keybase.io CLI installer/updater"
      prog : find_bin()

    add_option_dict @ap, Main.OPTS
    null

  #-----------

  parse_args : (cb) ->
    err = @arg_parse_init()
    if not err?
      @argv = @ap.parse_args process.argv[2...]
      if @argv.opts.about
        @cmd = new AboutCommand @argv
      else
        err = new Error "unimplemented command"
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
    cb null

##========================================================================

exports.run = run = () -> (new Main).main()

##========================================================================
