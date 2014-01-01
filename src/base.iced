
##========================================================================

exports.BaseCommand = class BaseCommand
  constructor : (@argv) ->
  run : (cb) -> cb new Error "unimplemented"

##========================================================================

