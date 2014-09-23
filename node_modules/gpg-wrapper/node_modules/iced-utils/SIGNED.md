##### Signed by https://keybase.io/max
```
-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.22 (Darwin)
Comment: GPGTools - http://gpgtools.org

iQEcBAABAgAGBQJTvDiWAAoJEJgKPw0B/gTfhZUIAMutda6p35fVUqrXLOWFRIX7
SnBHDtQvlfsHB3y/qwi3hzqRQb3hvLpxgQmxBuobDrjw2FIfCQcxh5dP2n+8uNTj
Art+xqRlnlfF7nhWn6cFoNq6JCixGbF3sMoQ8GUB1HeqRImlGQOgmDQMvHzzEzvK
VaqL9LnF87+xESWwtECqSs1TL6iGO6Dg3DuRu9+tUDY7FMsswZH6UR4CHknIyAzF
dZuDLv5mX8MsFBBGCbQM5xlSq+NI7PD2bRkFMRUTItW0lnDsLtxMwjjD8jxVDo47
EkfeDO8xgatjEEEOM/NQx4LmTcGIMlAruNvazPed+Lkn6cTgZCUA36srXTdEYDM=
=yZ/6
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size   exec  file                   contents                                                        
             ./                                                                                     
110            .gitignore           71f9c0f0263e54e773253b0ff92e43970e8288db495d9638ac2bfecee2d2f43b
608            CHANGELOG.md         abd1d6b8dcc0a66e73d565c4db3c816d8a5b5decc12457fdaadad966770f4fc6
506            Makefile             ffccd2051ddad6b7c95582f8f218abcb160761fdcb24a76395a54947cb5ad77b
119            README.md            631d836cb2b1e05957d9da1eb7d7e5dd2db3ce83edc6d5f8d1f8dd84c0ca5e96
               lib/                                                                                 
1305             drain.js           4ea0841d2cf07b872e72048043946a1e016ccf09c917455a2bee9c6a358dd7a9
360              enum.js            d22333c1a5e72e0978dc301447aa4e285144f49bdd08e631836e1da5c57b2877
11420            fs.js              0983493f7c1850b57d007a2d30d6d96c74da3575298f6df6d693f76330ec97fc
1935             getopt.js          7019aac910b460cedff284214edbda2c9abf77f426b4e6328ef21fc0d1a48b6f
2684             gets.js            3a1079865745407c40aba3349a4bf92f7440015d1e8a62b731e5ee296673243b
3192             lock.js            c61d1fc71c496ee0ec7985954fbe9c1946062e30ab68417d35e4c37113977f8f
19414            lockfile.js        c6aa2fa7e2cc2d97fbd03a1da8690fd729824cd4298ee1636841dd3053aff932
423              main.js            77891c8cd0c92c7cbd4308ba1a79f579170b02f3fed7e2749a39906db2a02ac7
5492             spawn.js           fdd6367e1ad33a04f235c02fa0fbeeff81df1ded2dfeac6571fb7236da25497d
10724            util.js            bb3c21b7459ef37e54363c84a162c3c12e2fcd6b2ab1e42bd481913380e5e9ca
665            package.json         b7f97001232d394909d4776dd232a5ecbe96c4fef833fd1b5c998ef86ea4cacf
               src/                                                                                 
988              drain.iced         72d252ab54233c0dc16a94c55d8dc6b2227a03efab73ebf58a29d42919a910a0
275              enum.iced          189271c330eb6db654879469828332cf78ea87e210d1d7275611a2e1e1fb4d15
1756             fs.iced            205ad199023ba430ce4b6771913424f0872c90ed79afc13cc919159653e389ad
1108             getopt.iced        ecea3528970970453687a0ac7b10c943d37e4df861a345a7bb6faee238032cdd
2081             gets.iced          e289a75c4d10cba1f7e156df5637b3e0989c0ebefd2842b3262988347de4787b
1123             lock.iced          00e0aad9cbe1aac2031640a78d7f6a71e05975af1850b815311f9290f9ce2fd9
5009             lockfile.iced      4965dea73b8739ab499704c8213f9d4c875f7271907e41ebd0ea90c79db35aa4
308              main.iced          de11b3ce29e469a3c111c939df9f9466a5ede914febbbfcd401a8c1842741e05
2621             spawn.iced         c8f801be169434cf2a6dd8650f12d71c3656e098d3ca6b8f3234c47b1e497997
7326             util.iced          53c7437de325cfcd4270fe61fcc12e626f242e6e2a04b2b636bdceb4d19368f3
               test/                                                                                
                 files/                                                                             
1063               dict_merge.iced  3a42886bd8bd895beedfa82e67535e1721951aa05f7fb5257f235ec31e10dd1a
357                drain.iced       181131d2a8f176b591ae58b64dfbbfbb80c47c9bf617b02199672eec2880efc8
183              run.iced           822568debeae702ca4d1f3026896d78b2d426e960d77cb3c374da059ef09f9fd
```

#### Ignore

```
/SIGNED.md
```

#### Presets

```
git      # ignore .git and anything as described by .gitignore files
dropbox  # ignore .dropbox-cache and other Dropbox-related files    
kb       # ignore anything as described by .kbignore files          
```

<!-- summarize version = 0.0.9 -->

### End signed statement

<hr>

#### Notes

With keybase you can sign any directory's contents, whether it's a git repo,
source code distribution, or a personal documents folder. It aims to replace the drudgery of:

  1. comparing a zipped file to a detached statement
  2. downloading a public key
  3. confirming it is in fact the author's by reviewing public statements they've made, using it

All in one simple command:

```bash
keybase dir verify
```

There are lots of options, including assertions for automating your checks.

For more info, check out https://keybase.io/docs/command_line/code_signing