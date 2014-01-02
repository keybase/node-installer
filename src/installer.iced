
{BaseCommand} = require './base'
{assert_exactly_one,gpg} = require 'gpg-wrapper'
{make_esc} = require 'iced-error'
{key,short_id} = require './key'
request = require 'request'
{fullname} = require './package'
{constants} = require './constants'

##========================================================================

url_join = (args...) ->
  parts = [ args[0] ]
  for arg in args[1...]
    if parts[-1...][0][-1...][0] isnt '/' then parts.push '/'
    parts.push arg
  parts.join ''

##========================================================================

exports.Installer = class Installer extends BaseCommand

  import_key : (cb) ->
    esc = make_esc cb, "Installer::import_key"
    keybuf = new Buffer key, 'utf8'
    args = [ "--import" ]
    await gpg { args, stdin : keybuf, quiet : true }, esc defer out
    await assert_exactly_one short_id, esc defer()
    cb null

  #------------

  fetch_package : (cb) ->
    prefix = @argv.get("url-prefix", "u") or constants.url_prefix
    file = @argv.get()?[0] or "latest-stable"
    url = url_join(prefix, file)
    headers = { "X-Keybase-Installer" : fullname() }
    opts =  { url, headers }
    console.log "Fetching archive: #{url}"
    await request opts, defer err, res, body
    if err?
      err = new Error "Error in fetch: #{err.message}"
    cb err

  #------------

  verify_package : (cb) ->
    cb null

  #------------

  install_package : (cb) ->
    cb null

  #------------
  
  run : (cb) ->
    esc = make_esc cb, "Installer::run"
    await @import_key      esc defer()
    await @fetch_package   esc defer()
    await @verify_package  esc defer()
    await @install_package esc defer()
    cb null

##========================================================================

