
https = require 'https'
{parse} = require 'url'
ProgressBar = require 'progress'

#========================================================================

cacert = """-----BEGIN CERTIFICATE-----
MIIGmzCCBIOgAwIBAgIJAPzhpcIBaOeNMA0GCSqGSIb3DQEBBQUAMIGPMQswCQYD
VQQGEwJVUzELMAkGA1UECBMCTlkxETAPBgNVBAcTCE5ldyBZb3JrMRQwEgYDVQQK
EwtLZXliYXNlIExMQzEXMBUGA1UECxMOQ2VydCBBdXRob3JpdHkxEzARBgNVBAMT
CmtleWJhc2UuaW8xHDAaBgkqhkiG9w0BCQEWDWNhQGtleWJhc2UuaW8wHhcNMTQw
MTAyMTY0MjMzWhcNMjMxMjMxMTY0MjMzWjCBjzELMAkGA1UEBhMCVVMxCzAJBgNV
BAgTAk5ZMREwDwYDVQQHEwhOZXcgWW9yazEUMBIGA1UEChMLS2V5YmFzZSBMTEMx
FzAVBgNVBAsTDkNlcnQgQXV0aG9yaXR5MRMwEQYDVQQDEwprZXliYXNlLmlvMRww
GgYJKoZIhvcNAQkBFg1jYUBrZXliYXNlLmlvMIICIjANBgkqhkiG9w0BAQEFAAOC
Ag8AMIICCgKCAgEA3sLA6ZG8uOvmlFvFLVIOURmcQrZyMFKbVu9/TeDiemls3w3/
JzVTduD+7KiUi9R7QcCW/V1ZpReTfunm7rfACiJ1fpIkjSQrgsvKDLghIzxIS5FM
I8utet5p6QtuJhaAwmmXn8xX05FvqWNbrcXRdpL4goFdigPsFK2xhTUiWatLMste
oShI7+zmrgkx75LeLMD0bL2uOf87JjOzbY8x2sUIZLGwPoATyG8WS38ey6KkJxRj
AhG3p+OTYEjYSrsAtQA6ImbeDpfSHKOB8HF3nVp//Eb4HEiEsWwBRbQXvAWh3DYL
GukFW0wiO0HVCoWY+bHL/Mqa0NdRGOlLsbL4Z4pLrhqKgSDU8umX9YuNRRaB0P5n
TkzyU6axHqzq990Gep/I62bjsBdYYp+DjSPK43mXRrfWJl2NTcl8xKAyfsOW+9hQ
9vwK0tpSicNxfYuUZs0BhfjSZ/Tc6Z1ERdgUYRiXTtohl+SRA2IgZMloHCllVMNj
EjXhguvHgLAOrcuyhVBupiUQGUHQvkMsr1Uz8VPNDFOJedwucRU2AaR881bknnSb
ds9+zNLsvUFV+BK7Qdnt/WkFpYL78rGwY47msi9Ooddx6fPyeg3qkJGM6cwn/boy
w9lQeleYDq8kyJdixIAxtAskNzRPJ4nDu2izTfByQoM8epwAWboc/gNFObMCAwEA
AaOB9zCB9DAdBgNVHQ4EFgQURqpATOw1gVVrzlqqFKbkfaKXvwowgcQGA1UdIwSB
vDCBuYAURqpATOw1gVVrzlqqFKbkfaKXvwqhgZWkgZIwgY8xCzAJBgNVBAYTAlVT
MQswCQYDVQQIEwJOWTERMA8GA1UEBxMITmV3IFlvcmsxFDASBgNVBAoTC0tleWJh
c2UgTExDMRcwFQYDVQQLEw5DZXJ0IEF1dGhvcml0eTETMBEGA1UEAxMKa2V5YmFz
ZS5pbzEcMBoGCSqGSIb3DQEJARYNY2FAa2V5YmFzZS5pb4IJAPzhpcIBaOeNMAwG
A1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggIBAA3Z5FIhulYghMuHdcHYTYWc
7xT5WD4hXQ0WALZs4p5Y+b2Af54o6v1wUE1Au97FORq5CsFXX/kGl/JzzTimeucn
YJwGuXMpilrlHCBAL5/lSQjA7qbYIolQ3SB9ON+LYuF1jKB9k8SqNp7qzucxT3tO
b8ZMDEPNsseC7NE2uwNtcW3yrTh6WZnSqg/jwswiWjHYDdG7U8FjMYlRol3wPux2
PizGbSgiR+ztI2OthxtxNWMrT9XKxNQTpcxOXnLuhiSwqH8PoY17ecP8VPpaa0K6
zym0zSkbroqydazaxcXRk3eSlc02Ktk7HzRzuqQQXhRMkxVnHbFHgGsz03L533pm
mlIEgBMggZkHwNvs1LR7f3v2McdKulDH7Mv8yyfguuQ5Jxxt7RJhUuqSudbEhoaM
6jAJwBkMFxsV2YnyFEd3eZ/qBYPf7TYHhyzmHW6WkSypGqSnXd4gYpJ8o7LxSf4F
inLjxRD+H9Xn1UVXWLM0gaBB7zZcXd2zjMpRsWgezf5IR5vyakJsc7fxzgor3Qeq
Ri6LvdEkhhFVl5rHMQBwNOPngySrq8cs/ikTLTfQVTYXXA4Ba1YyiMOlfaR1LhKw
If1AkUV0tfCTNRZ01EotKSK77+o+k214n+BAu+7mO+9B5Kb7lMFQcuWCHXKYB2Md
cT7Yh09F0QpFUd0ymEfv
-----END CERTIFICATE-----
"""

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
      ca : [ cacert ]
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
  opts.progress = 50000
  urls = {}
  lim = opts.maxRedirects or 10
  err = new Error "Too many redirects"
  res = body = null
  for i in [0...lim] 
    await single opts, defer err, res, body
    if not (res.statusCode in [301, 302]) then break
    else if not (url = res.headers?.location)?
      err = new Error "Can't find a location in header for redirect"
      break
    else 
      opts.url = url
  cb err, res, body

#============================================================================

