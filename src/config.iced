
{constants} = require './constants'

##==============================================================

url_join = (args...) ->
  parts = [ args[0] ]
  for arg in args[1...]
    if parts[-1...][0][-1...][0] isnt '/' then parts.push '/'
    parts.push arg
  parts.join ''

#==========================================================

exports.Config = class Config

  #--------------------

  constructor : (@argv) ->

  #--------------------

  url_prefix : () -> @argv("u", "url-prefix") or contants.url_prefix

  #--------------------

  make_url : (u) -> url_join @url_prefix(), u

#==========================================================

