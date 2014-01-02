
{Engine} = require 'gpg-wrapper'

##-----------------------------------

exports.npm = npm = ({args}, cb) ->
  eng = (new Engine { args } )
  eng.name = "npm"
  await eng.run().wait defer rc
  if rc isnt 0
    err = new Error "npm exit code #{rc}"
    err.rc = rc
  cb err

##-----------------------------------
