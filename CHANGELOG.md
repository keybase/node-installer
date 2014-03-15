## 0.1.11 (2014-03-14)

Bugfixes:

  - Close keybase/keybase-issues#190 --- some versions of GPG print the fingerprint
    of the subkey too, so we should be ok with getting >1 (let's just call it <=2) 
    fingerprint on `gpg -k --fingerprint`.

## 0.1.10 (2014-03-10)

Features:

  - Enable the https_proxy and http_proxy environment variables

## 0.1.9 (2014-03-10)

Features:

  - Enable -x/--proxy flag for proxying the install through the given proxy

Cleanups:

  - Cleanup usage message

## 0.1.8 (2014-03-05)

Bugfixes:
 
  - Close #41 -- buggy doc message
  - Close #44 -- poop out on old version of node

## 0.1.7 (2014-03-03)

Bugfixes:

  - Fix keybase/keybase-installer#39 --- do the install check for --prefix
    if --prefix was specified.

## 0.1.6 (2014-03-03)

Features:
  
  - Better administrator install message on windows
  - Allow --prefix to specify a non-standard install location (#38)
  - A welcome message.

## 0.1.5 (2014-02-20)

Features:

  - Better error messages if you lack the permissions to run npm install without root.

## 0.1.4 (2014-02-18)

Bugfixes:

  - Close #32, another bug in windows.  Using the USERPROFILE environment
  variable rather than HOMEDIR, since the former works with path concatenations,
  and the latter doesn't seem to.

## 0.1.3 (2014-02-18)

Bugfixes:

  - Upgrade to gpg-wrapper v0.0.32 to solve a bug in keydir creation

## 0.1.2 (2014-02-18)

Bugfixes:

  - More bugfixes on windows; we had a crash on keyring on a Windows 7 Pro,
    GPG 2.0.22. I think it's this bug that gpg won't index the keyring if there's not a 
    pubring.gpg file there.  Fix with an upgrade to gpg-wrapper v0.0.31.

## 0.1.1 (2014-02-17)

Bugfixes:

  - Upgrade to gpg-wrapper v0.0.30
  - Fix bug in key upgrade protocol, with setting the final key version causing a crash
  - Fix bug in key upgrade protocol for if we have the code key but not the index key
  - Fallback to a lower keyring-resident key if the most recent one failed in the above
  check. It's always safer for to use the local keys than the ones that came with the software.
  - Fix bug #31, a cleanup error in Windows.

Features:

  - Add config::set_master_ring for server-ops
  - Operational on Windows!

## 0.1.0 (2014-02-17)

Bugfixes:

  - Use `iced-spawn` rather than the spawn logic in `gpg-utils`.
  - Upgrade to `gpg-utils` to v0.0.29
  - Hopefully some fixes for windows; it is tested to work now at least once.
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
