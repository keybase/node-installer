{constants} = require './constants'
{fullname} = require './package'
request = require './request'
log = require './log'
{tmpdir} = require 'os'
fs = require 'fs'
{chain,make_esc} = require 'iced-error'
{a_json_parse,base64u} = require('iced-utils').util
{prng} = require 'crypto'
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

  constructor : (@argv, master_ring) ->
    @_tmpdir = null
    @_master_ring = master_ring or keyring.master_ring()

  #--------------------

  master_ring : () -> @_master_ring
  set_master_ring : (r) -> @_master_ring = (r or keyring.master_ring())

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
      r = base64u.encode(prng(16))
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

  request : (u, cb) ->
    url = if u.match("^https?://") then u else @make_url(u)
    opts = 
      url : url
      headers : { "X-Keybase-Installer" : fullname() },
      maxRedirects : 10
      progress : 50000
    log.info "Fetching URL #{url}"
    await request opts, defer err, res, body
    log.debug " * fetched -> #{res?.statusCode}"
    cb err, res, body

  #--------------------

  set_key_version : (v) ->
    @_key_version = v
    log.info "Using key version v#{v}"

  #--------------------

  key_version : () -> @_key_version

  #--------------------

  set_index : (i) -> @_index = i
  index : () -> @_index

  #--------------------

  oneshot_verify : ({which, sig, file}, cb) ->
    query = key_query @_key_version, which
    await @master_ring().oneshot_verify {query, file, sig, single: true}, defer err, json
    cb err, json

#==========================================================

