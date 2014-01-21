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
{keyring} = require 'gpg-wrapper'
{key_query} = require './util'

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
    @_tmpdir = null

  #--------------------

  url_prefix : () -> @argv.get("u", "url-prefix") or constants.url_prefix

  #--------------------

  make_url : (u) -> url_join @url_prefix(), u

  #--------------------

  get_tmpdir : () -> @_tmpdir

  #--------------------

  make_tmpdir : (cb) ->
    err = null
    unless @_tmpdir?
      r = base64u.encode(rng(16))
      @_tmpdir = path.join(tmpdir(), "keybase_install_#{r}");
      await fs.mkdir @_tmpdir, 0o700, defer err
      log.info "Made temporary directory: #{@_tmpdir}"
    cb err

  #------------

  cleanup : (cb) ->
    esc = make_esc cb, "Installer::cleanup"
    if not @_tmpdir? then # noop
    else if @argv.get("C","skip-cleanup")
      log.info "Preserving tmpdir #{@_tmpdir} as per command-line switch"
    else 
      log.info "cleaning up tmpdir #{@_tmpdir}"
      await fs.readdir @_tmpdir, esc defer files
      for f in files
        p = path.join @_tmpdir, f
        await fs.unlink p, esc defer()
      await fs.rmdir @_tmpdir, esc defer()
    cb null

  #--------------------

  make_oneshot_ring : (which, cb) ->
    query = key_query @_key_version, which
    await keyring.master_ring().make_oneshot_ring { query, single : true }, defer err, ring
    cb err, ring

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

