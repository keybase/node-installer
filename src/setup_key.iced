
##========================================================================

exports.SetupKeyRunner = new Class SetupKeyRunner

  constructor : () ->

  #------------

  run : (cb) ->
    await @find_latest_key defer err, key
    unless key?
      await @install_key defer err, key
    cb err

  #------------

##========================================================================
