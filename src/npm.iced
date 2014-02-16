{run} = require 'iced-spawn'
{exec} = require 'child_process'

_config = null

##-----------------------------------

exports.set_config = (c) -> _config = c

##-----------------------------------

exports.npm = npm = ({args}, cb) ->
  name = _config.get_cmd 'npm'
  await run { args, name }, defer err
  cb err

##-----------------------------------

exports.check = check_cmd = (cb) ->
  await npm { args : [ "version" ] }, defer err
  cb err

##-----------------------------------
