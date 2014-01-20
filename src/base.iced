
{Config} = require './config'

##========================================================================

exports.BaseCommand = class BaseCommand
  constructor : (argv) ->
    @config = new Config argv
  run : (cb) -> cb new Error "unimplemented"

##========================================================================

