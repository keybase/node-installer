
https = require 'https'
{parse} = require 'url'
ProgressBar = require 'progress'

#========================================================================

class Request

  constructor : ({url, uri, @headers, progress}) ->
    url = url or uri
    @_res = null
    @_data = []
    @_err = null
    @uri = @url = if typeof(url) is 'string' then parse(url) else url
    @_bar = null
    @_opts = { progress }

  #--------------------

  run : (cb) ->
    @_done_cb = cb
    @_launch()

  #--------------------

  _make_opts : () ->
    opts = 
      host : @url.hostname
      port : @url.port or 443
      path : @url.path
      method : 'GET'
      headers : @headers
      rejectUnauthorized : true
    opts.agent = new https.Agent opts
    opts

  #--------------------

  _launch : () ->
    opts = @_make_opts()
    req = https.request opts, (res) =>
      if @_opts.progress? and (l = res.headers?["content-length"])? and 
         not(isNaN(l = parseInt(l,10))) and l > @_opts.progress
        @_bar = new ProgressBar "Download #{@url.path} [:bar] :percent :etas (#{l} bytes total)", {
          complete : "=",
          incomplete : ' ',
          width : 50,
          total : l
        }
      @_res = res
      res.request = @
      res.on 'data', (d) => 
        @_data.push d
        @_bar?.tick(d.length)
      res.on 'end',  () => @_finish()
    req.end()
    req.on 'error', (e) => 
      @_err = e
      @_finish()

  #--------------------

  _finish : () ->
    cb = @_done_cb
    @_done_cb = null
    cb @_err, @_res, (Buffer.concat @_data)

#=============================================================================

single = (opts, cb) -> (new Request opts).run cb

#=============================================================================

module.exports = request = (opts, cb) ->
  lim = opts.maxRedirects or 10
  res = body = null
  found = false
  for i in [0...lim] 
    await single opts, defer err, res, body
    if err? then break
    else if not (res.statusCode in [301, 302]) then found = true
    else if not (url = res.headers?.location)?
      err = new Error "Can't find a location in header for redirect"
      break
    else 
      opts.url = url

  err = if err? then err 
  else if found then null
  else new Error "Too many redirects"

  cb err, res, body

#============================================================================

