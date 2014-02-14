{Engine} = require 'gpg-wrapper'
{exec} = require 'child_process'

_config = null

##-----------------------------------

exports.set_config = (c) -> _config = c

##-----------------------------------

exports.check = check_cmd = (cb) ->
  cmd = _config.get_cmd 'npm'
  await exec "#{cmd} version", defer err
  cb err

##-----------------------------------

exports.npm = npm = ({args}, cb) ->
  eng = (new Engine { args } )
  eng.name = _config.get_cmd 'npm'
  await eng.run().wait defer rc
  if rc isnt 0
    err = new Error "npm exit code #{rc}"
    err.rc = rc
  cb err

##-----------------------------------
