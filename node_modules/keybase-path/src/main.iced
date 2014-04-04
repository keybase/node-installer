
pathmod = require 'path'

#================

class Base
	constructor : () ->

#================

class Sane extends Base
	constructor : () ->
		@sep = pathmod.sep
	split : (x) -> x.split @sep
	join :  (v...) -> v.join @sep
	home : (opts = {}) -> 
		ret = process.env.HOME
		if opts.array then @split(ret) else ret
	normalize : (p) -> p

#================

lst = (v) -> v[-1...][0]

#================

class Insane extends Base

	split : (x) -> x.split /[/\\]/ 
	join : (v...) -> v.join '/'
	normalize : (p) -> @join @split p

	home : (opts = {}) ->
		ret = null
		err = if not (e = process.env.TEMP)? then new Error "No env.TEMP variable found"
		else if (p = @split(e)).length is 0 then new Error "Malformed env.TEMP variable"
		else if not (p.pop().match /^te?mp$/i) then new Error "TEMP didn't end in \\Temp"
		else
			if lst(p).toLowerCase() is "local" and not opts.local
				p.pop()
				p.push "Roaming"
			ret = if opts.array then p else @join(p...)
		if err? then throw err
		return ret

#================

_eng = if process.platform is 'win32' then (new Insane()) else (new Sane())

for sym in [ 'split', 'join', 'home', 'normalize' ]
	exports[sym] = _eng[sym].bind(_eng)

#================

