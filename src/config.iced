{constants} = require './constants'
{fullname} = require './package'
request = require './request'
log = require './log'
{tmpdir} = require 'os'
fs = require 'fs'
{make_esc} = require 'iced-error'
{base64u} = require('iced-utils').util
{rng} = require 'crypto'
path = require 'path'

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
    @tmpdir = null

  #--------------------

  url_prefix : () -> @argv.get("u", "url-prefix") or constants.url_prefix

  #--------------------

  make_url : (u) -> url_join @url_prefix(), u

  #--------------------

  make_tmpdir : (cb) ->
    err = null
    unless @tmpdir?
      r = base64u.encode(rng(16))
      @tmpdir = path.join(tmpdir(), "keybase_install_#{r}");
      await fs.mkdir @tmpdir, 0o700, defer err
      log.info "Made temporary directory: #{@tmpdir}"
    cb err

  #------------

  cleanup : (cb) ->
    esc = make_esc cb, "Installer::cleanup"
    if not @tmpdir? then # noop
    else if @argv.get("C","skip-cleanup")
      log.info "Preserving tmpdir #{@tmpdir} as per command-line switch"
    else 
      log.info "cleaning up tmpdir #{@tmpdir}"
      await fs.readdir @tmpdir, esc defer files
      for f in files
        p = path.join @tmpdir, f
        await fs.unlink p, esc defer()
      await fs.rmdir @tmpdir, esc defer()
    cb null

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

  #--------------------

  set_key_version : (v) ->
    @_key_version = v
    log.info "Using key version v#{v}"

  #--------------------

  key_version : () -> @_key_version

#==========================================================

