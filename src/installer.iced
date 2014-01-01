
{BaseCommand} = require './base'
{gpg} = require 'gpg-wrapper'
{make_esc} = require 'iced-error'

##========================================================================

exports.Installer = class Installer extends BaseCommand

  import_key : (cb) ->
    cb null

  fetch_package : (cb) ->
    cb null

  verify_package : (cb) ->
    cb null

  install_package : (cb) ->
    cb null

  run : (cb) ->
    esc = make_esc cb, "Installer::run"
    await @import_key      esc defer()
    await @fetch_package   esc defer()
    await @verify_package  esc defer()
    await @install_package esc defer()
    cb null

##========================================================================

