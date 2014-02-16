## 0.0.12

Bugfixes:

	- Use `iced-spawn` rather than the spawn logic in `gpg-utils`.
	- Upgrade to `gpg-utils` to v0.0.27
	- Hopefully some fixes for windows

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
