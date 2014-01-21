
{json_stringify_sorted} = require('iced-utils').util
{createHash} = require 'crypto'

#===========================================================================

exports.hash_json = (x) -> 
  createHash('SHA512').update(json_stringify_sorted(x)).digest('hex')
  
#===========================================================================

