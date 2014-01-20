
{make_esc} = require 'iced-error'

##========================================================================

exports.KeyInstall = class KeyInstall

  constructor : (@config, @key) ->

  run : (cb) ->
    esc = make_esc cb, "KeyInstall::run"
    cb null

##========================================================================

