{constants} = require './constants'
{fullname} = require './package'
request = require './request'
log = require './log'

##==============================================================

url_join = (args...) ->
  rxx = /// ^(/*) (.*?) (/*)$ ///
  trim = (s) -> if (m = s.match(rxx))? then m[2] else s
  parts = (trim(a) for a in args)
  parts.join '/'

#==========================================================

exports.Config = class Config

  #--------------------

  constructor : (@argv) ->

  #--------------------

  url_prefix : () -> @argv.get("u", "url-prefix") or constants.url_prefix

  #--------------------

  make_url : (u) -> url_join @url_prefix(), u

  #--------------------

  request : (u, cb) ->
    url = @make_url u
    opts = 
      url : url
      headers : { "X-Keybase-Installer" : fullname() },
      maxRedirects : 10
      progress : 50000
    log.debug "+ Fetching URL #{url}"
    await request opts, defer err, res, body
    log.debug "- Fetched -> #{res?.statusCode}"
    cb err, res, body

#==========================================================

