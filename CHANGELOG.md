## 0.1.1 (2014-02-17)

Bugfixes:

	- Upgrade to gpg-wrapper v0.0.29 final
	- Fix bug in key upgrade protocol, with setting the final key version causing a crash
	- Fix bug in key upgrade protocol for if we have the code key but not the index key
	- Fallback to a lower keyring-resident key if the most recent one failed in the above
	check. It's always safer for to use the local keys than the ones that came with the software.

Features:

	- Add config::set_master_ring for server-ops

## 0.1.0 (2014-02-17)

Bugfixes:

	- Use `iced-spawn` rather than the spawn logic in `gpg-utils`.
	- Upgrade to `gpg-utils` to v0.0.29
	- Hopefully some fixes for windows; it is tested to work now
          at least once.
	- Fix bug #18; store keys to a private keyring rather than the main
	  keyring, this is much safer.

Cleanups:

	- Get rid of the `getopt` here, which moved into `iced-utils`

## 0.0.11 (2014-2-14)

Bugfixes:
  
	- Look for `npm` in path and fail more gracefully
	- Allow specification of alternate `npm` if you want that.
	- Upgrade to gpg-wrapper v0.0.25, for less dependence on parsing GPG text output.
	- More debugger output for debugging problems in the wild

## 0.0.10 (2014-2-13)

Bugfixes:

	- Unbreak `set_key_version`, which should be called whenever we call `find_latest_key`

Features:

	- Inaugural Changelog!
