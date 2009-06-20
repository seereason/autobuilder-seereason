module Targets where

import Data.List (isPrefixOf)
import Debian.AutoBuilder.ParamClass (Target(..))

------------------------ TARGETS ---------------------

publicTargets release =
    ghc610CoreTargets release ++	-- The compiler and our packaging tools
    autobuilderTargets release ++	-- The autobuilder and its dependencies
    ghc610Targets release ++		-- Haskell targets
    otherTargets release		-- Non-haskell targets

useGHC6102 release = True

-- If True, use an unmodified version of Debian's current
-- haskell-devscripts.  In addition, a dummy version of our
-- haskell-cdbs is built which replaces our hlibrary.mk file with a
-- link to Debian's.
useStandardDevscripts release = False

-- Information about how to obtain and assemble the source code for
-- the packages we want to build.

ghc610CoreTargets release =
    [ Target { sourcePackageName = "haskell-bzlib"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/bzlib/0.5.0.0/bzlib-0.5.0.0.tar.gz:ab594aaf9998ed602f8b23dd25199e19):(darcs:http://src.seereason.com/ghc610/debian/haskell-bzlib-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-zlib"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/zlib/0.5.0.0/zlib-0.5.0.0.tar.gz:22fa6d394c42c8584b234799b923f860):(darcs:http://src.seereason.com/ghc610/debian/haskell-zlib-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-cdbs"
             , sourceSpec = if useStandardDevscripts release
                            then "darcs:http://src.seereason.com/haskell-cdbs-dummy"
                            else "darcs:http://src.seereason.com/haskell-cdbs"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-unixutils"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/haskell-unixutils"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-cpphs"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/cpphs/1.6/cpphs-1.6.tar.gz:8a7565ff3b2d7bdb594af4c10c594951):(darcs:http://src.seereason.com/ghc610/debian/cpphs-debian)"
             , relaxInfo = ["cabal-debian"] }
    , Target { sourcePackageName = "haxml"
             , sourceSpec = "quilt:(apt:sid:haxml):(darcs:http://src.seereason.com/ghc610/quilt/haxml-quilt)"
             , relaxInfo = [] }
{-
-}
    , Target { sourcePackageName = "haskell-debian"
             , sourceSpec = if useGHC6102 release
                            then "darcs:http://src.seereason.com/ghc6102/haskell-debian-3"
                            else "darcs:http://src.seereason.com/ghc610/haskell-debian-3"
             , relaxInfo = ["cabal-debian"] }
    , Target { sourcePackageName = "haskell-debian-repo"
             , sourceSpec = if useGHC6102 release
                            then "darcs:http://src.seereason.com/ghc6102/haskell-debian-repo"
                            else "darcs:http://src.seereason.com/haskell-debian-repo"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-devscripts"
             , sourceSpec = if useStandardDevscripts release
                            then "apt:sid:haskell-devscripts"
                            else "quilt:(apt:sid:haskell-devscripts):(darcs:http://src.seereason.com/ghc6102/haskell-devscripts-quilt)"
                            -- "quilt:(uri:http://ftp.de.debian.org/debian/pool/main/h/haskell-devscripts/haskell-devscripts_0.6.15.tar.gz:996acac2c6fb2da2be9c5016f93a3c67):(darcs:http://src.seereason.com/ghc610/quilt/haskell-devscripts-quilt)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "ghc6"
             , sourceSpec = if useGHC6102 release
                            then "deb-dir:(uri:http://www.haskell.org/ghc/dist/6.10.2/ghc-6.10.2-src.tar.bz2:243d5857e5aa5f2f86e5e4c4437973fb):(darcs:http://src.seereason.com/debian/ghc6102-debian)"
                            else "deb-dir:(uri:http://www.haskell.org/ghc/dist/6.10.1/ghc-6.10.1-src.tar.bz2:54c676a632b3d73cf526b06347522c32):(darcs:http://src.seereason.com/ghc610/debian/ghc610-debian)"
             , relaxInfo = ["ghc6"
                           ,"xsltproc"
                           ,"haskell-devscripts"
                           ,"haddock"] }
{-
    -- Unpatched haskell-devscripts.  Using this leads to build
    -- failures because the postinst and postrm scripts don't pass the
    -- --global-conf argument to ghc-pkg.
    , Target { sourcePackageName = "haskell-devscripts"
             , sourceSpec = "apt:sid:haskell-devscripts"
             , relaxInfo = [] }
-}
    ] ++
    if useGHC6102 release
    then [ -- The haskell-time package is no longer included in the 6.10.2 compiler
           Target { sourcePackageName = "haskell-time"
                  , sourceSpec = "apt:sid:haskell-time"
                  , relaxInfo = [] }
         , Target { sourcePackageName = "haskell-extra"
                  , sourceSpec = "darcs:http://src.seereason.com/ghc6102/haskell-extra"
                  , relaxInfo = ["cabal-debian"] } ]
    else [ Target { sourcePackageName = "haskell-extra"
                  , sourceSpec = "darcs:http://src.seereason.com/ghc610/haskell-extra"
                  , relaxInfo = ["cabal-debian"] } ]

autobuilderTargets release =
    [ Target { sourcePackageName = "build-env"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/build-env"
             , relaxInfo = [] }
    , Target { sourcePackageName = "autobuilder"
             , sourceSpec = if useGHC6102 release
                            then "darcs:http://src.seereason.com/ghc6102/autobuilder"
                            else "darcs:http://src.seereason.com/ghc610/autobuilder"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-cgi"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/cgi/3001.1.7.1/cgi-3001.1.7.1.tar.gz:02b1d2fe6f271a17c1eb8b897fbd1d7f):(darcs:http://src.seereason.com/ghc610/debian/haskell-cgi-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-mime"
             , sourceSpec = if useGHC6102 release
                            then  "darcs:http://src.seereason.com/ghc6102/haskell-mime"
                            else "darcs:http://src.seereason.com/ghc610/haskell-mime"
             , relaxInfo = [] }
    , Target { sourcePackageName = "magic-haskell"
             , sourceSpec = "quilt:(apt:sid:magic-haskell):(darcs:http://src.seereason.com/ghc610/quilt/magic-haskell-quilt)"
             , relaxInfo = [] }
    ]

ghc610Targets release =
    [ Target { sourcePackageName = "haskell-utils"
             , sourceSpec = "quilt:(apt:sid:haskell-utils):(darcs:http://src.seereason.com/ghc610/quilt/haskell-utils-quilt)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-applicative-extras"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/applicative-extras/0.1.3/applicative-extras-0.1.3.tar.gz:50fa4c61e89654ea9858c304b4682680):(darcs:http://src.seereason.com/ghc610/debian/applicative-extras-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-formlets"
             , sourceSpec = "darcs:http://src.seereason.com/formlets"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-binary"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/binary/0.4.4/binary-0.4.4.tar.gz:48fc6454e82e0aec7f648be107bfc0b8):(darcs:http://src.seereason.com/ghc610/debian/binary-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-extensible-exceptions"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/extensible-exceptions/0.1.1.0/extensible-exceptions-0.1.1.0.tar.gz:7aba82acc64fa2f2dc89d8ac27e24a43):(darcs:http://src.seereason.com/ghc610/debian/extensible-exceptions-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-maybet"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/MaybeT/0.1.2/MaybeT-0.1.2.tar.gz:9864a3f34151217004f8c968fda5b427):(darcs:http://src.seereason.com/debian/MaybeT-debian)"
             , relaxInfo = [] }               
    , Target { sourcePackageName = "haskell-happstack-util"
             , sourceSpec = "cd:happstack-util:darcs:http://src.seereason.com/happstack"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happstack-data"
             , sourceSpec = "cd:happstack-data:darcs:http://src.seereason.com/happstack"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happstack-ixset"
             , sourceSpec = "cd:happstack-ixset:darcs:http://src.seereason.com/happstack"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happstack-server"
             , sourceSpec = "cd:happstack-server:darcs:http://src.seereason.com/happstack"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happstack-state"
             , sourceSpec = "cd:happstack-state:darcs:http://src.seereason.com/happstack"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happstack"
             , sourceSpec = "cd:happstack:darcs:http://src.seereason.com/happstack"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happstack-contrib"
             , sourceSpec = "cd:happstack-contrib:darcs:http://src.seereason.com/happstack"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happstack-extra"
             , sourceSpec = "darcs:http://src.seereason.com/happstack-extra"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happstack-facebook"
             , sourceSpec = "darcs:http://src.seereason.com/happstack-facebook"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-help"
             , sourceSpec = "darcs:http://src.seereason.com/haskell-help"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-hinotify"
             , sourceSpec = "deb-dir:(darcs:http://haskell.org/~kolmodin/code/hinotify):(darcs:http://src.seereason.com/ghc610/debian/hinotify-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-hspread"
             , sourceSpec = "quilt:(apt:sid:haskell-hspread):(darcs:http://src.seereason.com/ghc610/quilt/haskell-hspread-quilt)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-utf8-string"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/utf8-string/0.3.4/utf8-string-0.3.4.tar.gz:72d13d9453cdf721dd95bc18144a120a):(darcs:http://src.seereason.com/ghc610/debian/utf8-string-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happy"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/happy/1.18.2/happy-1.18.2.tar.gz:adb1679a1fa8cec74a6e621a4a277e98):(darcs:http://src.seereason.com/ghc610/debian/happy-debian)"
             , relaxInfo = ["happy"] }
    , Target { sourcePackageName = "haskell-src-exts"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/haskell-src-exts/0.4.3.1/haskell-src-exts-0.4.3.1.tar.gz:4ff97fdae2bca0da0194fcb80974b188):(darcs:http://src.seereason.com/ghc610/debian/haskell-src-exts-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-rjson"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/RJson/0.3.5/RJson-0.3.5.tar.gz:e69c34b295e067c169a15fc5327a9dd9):(darcs:http://src.seereason.com/ghc610/debian/RJson-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-json"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/json/0.4.3/json-0.4.3.tar.gz:1af33c67594f69048b69d4aeafeea03e):(darcs:http://src.seereason.com/debian/json-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-iconv"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/iconv"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-hslogger"
             , sourceSpec = if useGHC6102 release
                            then "deb-dir:(uri:http://hackage.haskell.org/packages/archive/hslogger/1.0.7/hslogger-1.0.7.tar.gz:74ff79b2abfec7e24b96925f06112c9f):(darcs:http://src.seereason.com/ghc6102/debian/hslogger-debian)"
                            else "deb-dir:(uri:http://hackage.haskell.org/packages/archive/hslogger/1.0.7/hslogger-1.0.7.tar.gz:74ff79b2abfec7e24b96925f06112c9f):(darcs:http://src.seereason.com/ghc610/debian/hslogger-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-http"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/HTTP/4000.0.4/HTTP-4000.0.4.tar.gz:6526c1ee59cd3aedc7aa380673c80ef1):(darcs:http://src.seereason.com/ghc610/debian/haskell-http-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-syb-with-class"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/syb-with-class"
             , relaxInfo = [] }
{-
    , Target { sourcePackageName = "happs-util"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/HAppS-Util"
             , relaxInfo = [] }
    , Target { sourcePackageName = "happs-data"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/HAppS-Data"
             , relaxInfo = [] }
    , Target { sourcePackageName = "happs-ixset"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/HAppS-IxSet"
             , relaxInfo = [] }
    , Target { sourcePackageName = "happs-state"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/HAppS-State"
             , relaxInfo = [] }
    , Target { sourcePackageName = "happs-server"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/HAppS-Server"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happs-extra"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/HAppS-Extra"
             , relaxInfo = [] }
-}
    , Target { sourcePackageName = "haskell-harp"
             , sourceSpec = "deb-dir:(darcs:http://code.haskell.org/HSP/harp):(darcs:http://src.seereason.com/ghc610/debian/harp-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-hjavascript"
             , sourceSpec = "deb-dir:(darcs:http://code.haskell.org/HSP/hjavascript):(darcs:http://src.seereason.com/ghc610/debian/hjavascript-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-hsx"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/hsx"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-hsp"
             , sourceSpec = "deb-dir:(darcs:http://src.seereason.com/ghc610/hsp):(darcs:http://src.seereason.com/ghc610/debian/hsp-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-formlets-hsp"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/happs-hsp-formlets"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-hsx-xhtml"
             , sourceSpec = "deb-dir:(darcs:http://code.haskell.org/HSP/hsx-xhtml):(darcs:http://src.seereason.com/ghc610/debian/hsx-xhtml-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-hjscript"
             , sourceSpec = "deb-dir:(darcs:http://code.haskell.org/HSP/hjscript):(darcs:http://src.seereason.com/ghc610/debian/hjscript-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-shellac"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/Shellac/0.9.1/Shellac-0.9.1.tar.gz:0a563883b3acedb9c0d4308b44772f0f):(darcs:http://src.seereason.com/ghc610/debian/shellac-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-frisby"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/frisby"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-decimal"
             , sourceSpec = "darcs:http://src.seereason.com/ghc610/decimal"
             , relaxInfo = [] }
    , Target { sourcePackageName = "vc-darcs"
             , sourceSpec = "darcs:http://src.seereason.com/vc-darcs"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-cabal-install"
             , sourceSpec = "deb-dir:(darcs:http://darcs.haskell.org/cabal-install):(darcs:http://src.seereason.com/ghc610/debian/cabal-install-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-uniplate"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/uniplate/1.2.0.3/uniplate-1.2.0.3.tar.gz:e0e10700870f5b9756d4097e640164ca):(darcs:http://src.seereason.com/ghc610/debian/uniplate-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-i18n"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/i18n/0.3/i18n-0.3.tar.gz:e59445b4ad743ab77c61a281cf942bbf):(darcs:http://src.seereason.com/ghc610/debian/i18n-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-stb-image"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/stb-image/0.1.1/stb-image-0.1.1.tar.gz:9e8ac1305c60e13d04359744976e402a):(darcs:http://src.seereason.com/ghc610/debian/stb-image-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-gd"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/gd/3000.4.0/gd-3000.4.0.tar.gz:7bc5bb68638b807d592aba433beb3fa5):(darcs:http://src.seereason.com/ghc610/debian/haskell-gd-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-cc-delconto"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/CC-delcont/0.2/CC-delcont-0.2.tar.gz:e52149fca9bf76330a7c159917152790):(darcs:http://src.seereason.com/ghc610/debian/CC-delcont-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-debian-mirror"
             , sourceSpec = if useGHC6102 release
                            then "darcs:http://src.seereason.com/ghc6102/mirror"
                            else "darcs:http://src.seereason.com/mirror"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-archive"
             , sourceSpec = if useGHC6102 release
                            then "darcs:http://src.seereason.com/ghc6102/archive"
                            else "darcs:http://src.seereason.com/archive"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-orphanage"
             , sourceSpec = "darcs:http://src.seereason.com/haskell-orphanage"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-hstringtemplate"
             , sourceSpec = if useGHC6102 release
                            then "deb-dir:(uri:http://hackage.haskell.org/packages/archive/HStringTemplate/0.4.3/HStringTemplate-0.4.3.tar.gz:57139f6695f1c268ed38c34336191636):(darcs:http://src.seereason.com/ghc6102/debian/HStringTemplate-debian)"
                            else "deb-dir:(uri:http://hackage.haskell.org/packages/archive/HStringTemplate/0.4.3/HStringTemplate-0.4.3.tar.gz:57139f6695f1c268ed38c34336191636):(darcs:http://src.seereason.com/debian/HStringTemplate-debian)"
             , relaxInfo = [] }

    , Target { sourcePackageName = "haskell-consumer"
             , sourceSpec = "deb-dir:(darcs:http://www.n-heptane.com/nhlab/repos/haskell-consumer):(darcs:http://src.seereason.com/debian/haskell-consumer-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-urlt"
             , sourceSpec = "darcs:http://src.seereason.com/urlt"
             , relaxInfo = [] }

    , Target { sourcePackageName = "haskell-xml"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/xml/1.3.4/xml-1.3.4.tar.gz:841c3a36a0bfb2e46f88448ecc227cad):(darcs:http://src.seereason.com/debian/haskell-xml-debian)"
             , relaxInfo = [] }

    , Target { sourcePackageName = "haskell-feed"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/feed/0.3.6/feed-0.3.6.tar.gz:0abeeaa7870ef241ccdc5785e608a599):(darcs:http://src.seereason.com/debian/haskell-feed-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-digest"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/digest/0.0.0.5/digest-0.0.0.5.tar.gz:ba60cc9d1ad6d0795ad84390976699d1):(darcs:http://src.seereason.com/debian/haskell-digest-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-zip-archive"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/zip-archive/0.1.1.3/zip-archive-0.1.1.3.tar.gz:edf3924c929b5592b1b9dbf4853b754f):(darcs:http://src.seereason.com/debian/haskell-zip-archive-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-pandoc"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/pandoc/1.2/pandoc-1.2.tar.gz:402999cf17dd7072e4c8c7b6b6050ec3):(darcs:http://src.seereason.com/debian/haskell-pandoc-debian)"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-opengl"
             , sourceSpec = "apt:sid:haskell-opengl"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-glut"
             , sourceSpec = "apt:sid:haskell-glut"
             , relaxInfo = [] }

    , Target { sourcePackageName = "happstack-blog"
             , sourceSpec = "darcs:http://src.seereason.com/happstack-blog"
             , relaxInfo = []
             }

    , Target { sourcePackageName = "haskell-utility-ht"
            , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/utility-ht/0.0.5.1/utility-ht-0.0.5.1.tar.gz:98dcb042f404378d9071fc6344703386):(darcs:http://src.seereason.com/ghc610/debian/haskell-utility-ht)"
            , relaxInfo = []
            }

    , Target { sourcePackageName = "haskell-gnuplot"
            , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/gnuplot/0.3/gnuplot-0.3.tar.gz:4432a0e0b44ca7ceae8e6737cf0258fa):(darcs:http://src.seereason.com/ghc610/debian/haskell-gnuplot)"
            , relaxInfo = []
            }

{-
  "quilt:(apt:sid:hs-plugins):(darcs:http://src.seereason.com/ghc610/quilt/hs-plugins-quilt)"
    - Needs an older cabal
  "deb-dir:(darcs:http://src.seereason.com/HSP/happs-hsp-template):(darcs:http://src.seereason.com/debian/happs-hsp-template-debian)"
    - Depends on hs-plugins
  "deb-dir:(uri:http://hackage.haskell.org/packages/archive/cabal-install/0.6.0/cabal-install-0.6.0.tar.gz:ddce0bda54a99d816091e77ab6e4b39f):(darcs:http://src.seereason.com/ghc610/debian/cabal-install-debian)"
    - Requires 3000 < HTTP < 3002
  "deb-dir:(uri:http://hackage.haskell.org/packages/archive/readline/1.0.1.0/readline-1.0.1.0.tar.gz:eade9576def53ed293628a2f8580007e):(darcs:http://src.seereason.com/ghc610/debian/readline-debian)"
    - Can't find HsReadline.h
  "deb-dir:(uri:http://hackage.haskell.org/packages/archive/Shellac-readline/0.9/Shellac-readline-0.9.tar.gz:ffea10846cc5f40b84d6a4fe97c35ec9):(darcs:http://src.seereason.com/ghc610/debian/shellac-readline-debian)"
    - Requires readline
  "quilt:(apt:sid:darcs):(darcs:http://src.seereason.com/ghc610/quilt/darcs-quilt)"
    - Version 2.2.0 hangs when compiled with ghc 6.10 
  "deb-dir:(uri:http://hackage.haskell.org/packages/archive/regex-pcre-builtin/0.94.2.0.7.7/regex-pcre-builtin-0.94.2.0.7.7.tar.gz:1e7f7ca729d344caa20c8f57d18239dd):(darcs:http://src.seereason.com/ghc610/debian/regex-pcre-builtin-debian)"
    - setup-bin: At least the following dependencies are missing: regex-base >=0.93
-}
    ]

otherTargets release =
    [ Target { sourcePackageName = "tree-widget"
             , sourceSpec = "darcs:http://src.seereason.com/tree-widget"
             , relaxInfo = [] }
    -- This target fails during an arch only build, because it has no architecture dependent files.
    , Target { sourcePackageName = "seereason-keyring"
             , sourceSpec = "darcs:http://src.seereason.com/seereason-keyring"
             , relaxInfo = [] 
             }
    , Target { sourcePackageName = "jquery"
             , sourceSpec = "apt:sid:jquery"
             , relaxInfo = [] 
             }
    -- Waiting for this one to appear in sid
    , Target { sourcePackageName = "jqueryui"
             , sourceSpec = "darcs:http://src.seereason.com/jqueryui"
             , relaxInfo = [] 
             }
{-  We no longer need our own version of this.
    , Target { sourcePackageName = "haskell-tagsoup"
             , sourceSpec = "deb-dir:(uri:http://hackage.haskell.org/packages/archive/tagsoup/0.6/tagsoup-0.6.tar.gz:4db416463189292609b4cd3d0e867ccd):(darcs:http://src.seereason.com/debian/tagsoup-debian)"
             , relaxInfo = [] } -}
    ]

privateTargets release =
    [ Target { sourcePackageName = "haskell-filecache"
             , sourceSpec = "darcs:" ++ privateDarcsURI ++ "/haskell-filecache"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-document"
             , sourceSpec = "darcs:" ++ privateDarcsURI ++ "/haskell-document"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-appraisal"
             , sourceSpec = "darcs:" ++ privateDarcsURI ++ "/haskell-appraisal"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-happstack-mailinglist"
             , sourceSpec = "darcs:" ++ privateDarcsURI ++ "/mailingList"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-generic-formlets"
             , sourceSpec = "darcs:" ++ privateDarcsURI ++ "/generic-formlets-2"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-algebrazam"
             , sourceSpec = "darcs:" ++ privateDarcsURI ++ "/AlgebraZam"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-algebrazam-quiz"
             , sourceSpec = "darcs:" ++ privateDarcsURI ++ "/algebrazam-quiz"
             , relaxInfo = [] }
    , Target { sourcePackageName = "haskell-senioritymatters"
             , sourceSpec = "darcs:" ++ privateDarcsURI ++ "/SeniorityMatters"
             , relaxInfo = [] }
    ]
    where privateDarcsURI = "ssh://upload@deb.seereason.com/srv/darcs"


{-
  deb-dir:(darcs:http://code.haskell.org/checkers):(darcs:http://src.seereason.com/debian/checkers-debian)
  deb-dir:(uri:http://hackage.haskell.org/packages/archive/MemoTrie/0.0/MemoTrie-0.0.tar.gz):(darcs:http://src.seereason.com/debian/MemoTrie-debian)
  deb-dir:(darcs:http://darcs.haskell.org/packages/TypeCompose):(darcs:http://src.seereason.com/debian/TypeCompose-debian)
  deb-dir:(uri:http://hackage.haskell.org/packages/archive/Cabal/1.4.0.0/Cabal-1.4.0.0.tar.gz:5d8f10b95c42ac7419ac9673bfb6a607):(darcs:http://src.seereason.com/debian/cabal-debianization)
  deb-dir:(uri:http://hackage.haskell.org/packages/archive/ghc-paths/0.1.0.4/ghc-paths-0.1.0.4.tar.gz:a8f36dcb5407de9907b7d78b31fc24a1):(darcs:http://src.seereason.com/debian/ghc-paths-debian)
  quilt:(darcs:http://www.cs.york.ac.uk/fp/darcs/hscolour):(darcs:http://src.seereason.com/quilt/hscolour-quilt)
  darcs:http://src.seereason.com/haskell-ugly
  darcs:http://src.seereason.com/mirror
  darcs:http://src.seereason.com/backups
  quilt:(apt:sid:xtla):(darcs:http://src.seereason.com/xtla-quilt)
  proc:apt:gutsy:neko
  proc:apt:gutsy:haxe
  deb-dir:(uri:http://hackage.haskell.org/packages/archive/colour/1.0.0/colour-1.0.0.tar.gz:97b0802abbf3a71a3606642850fe46c7):(darcs:http://src.seereason.com/debian/colour-debian)
  apt:sid:alex
  apt:sid:bnfc
  deb-dir:(darcs:http://darcs.haskell.org/crypto):(darcs:http://src.seereason.com/debian/haskell-crypto-debian)
  apt:sid:darcs
  apt:sid:darcs-monitor
  apt:sid:drift
  apt:sid:frown
  darcs:http://www.n-heptane.com/nhlab/repos/haskell-agi
  quilt:(apt:hardy:haskell-binary):(darcs:http://src.seereason.com/quilt/haskell-binary-quilt)
  apt:sid:haskell-doc
  quilt:(apt:sid:haskell-edison):(darcs:http://src.seereason.com/quilt/edison-quilt)
  apt:sid:haskell-hlist
  quilt:(apt:sid:haskell-http):(darcs:http://src.seereason.com/quilt/haskell-http-quilt)
  apt:sid:haskell-mode
  apt:sid:haskell-uulib
  apt:sid:helium
  apt:hardy:hmake
  quilt:(apt:sid:hslogger):(darcs:http://src.seereason.com/quilt/hslogger-quilt)
  quilt:(apt:sid:ldap-haskell):(darcs:http://src.seereason.com/quilt/ldap-haskell-quilt)
  apt:sid:lhs2tex
  quilt:(apt:sid:magic-haskell):(darcs:http://src.seereason.com/quilt/magic-haskell-quilt)
  quilt:(apt:sid:pandoc):(darcs:http://src.seereason.com/quilt/pandoc-quilt)
  apt:sid:uuagc
  apt:sid:whitespace
  sourcedeb:darcs:http://src.seereason.com/haskell-wordnet
  quilt:(apt:sid:xmonad):(darcs:http://src.seereason.com/quilt/xmonad-quilt)
  darcs:http://src.seereason.com/hlibrary
  apt:sid:haskelldb
    - Needs doc architecture fix
  apt:hardy:haskell-hsql
    - Needs doc architecture fix
  apt:hardy:haskell-hsql-mysql
    - Needs doc architecture fix
  apt:hardy:haskell-hsql-odbc
    - Needs doc architecture fix
  apt:sid:haskell-hsql-postgresql
    - Needs doc architecture fix
  apt:hardy:haskell-hsql-sqlite3
    - Needs doc architecture fix
  apt:sid:c2hs
    - Needs doc architecture fix
  apt:sid:washngo
    - Needs patch
  apt:sid:ftphs
    - Needs patch
  apt:sid:haskell-anydbm
    - Needs patch
  apt:sid:haskell-configfile
    - Needs patch
  apt:sid:haskell-hsh
    - Needs patch
  apt:sid:listlike
    - Needs patch
  quilt:(apt:sid:missingh):(darcs:http://src.seereason.com/quilt/missingh-quilt)
    - Needs patch
  apt:sid:gtkrsync
    - Needs patch
  quilt:(apt:sid:gtk2hs):(darcs:http://src.seereason.com/quilt/gtk2hs-quilt)
    - Needs patch
  apt:sid:arch2darcs
    - Needs patch
  apt:sid:hg-buildpackage
    - Needs patch
  apt:sid:srcinst
    - Needs patch
  apt:sid:dfsbuild
    - Needs patch
  apt:sid:darcs-buildpackage
    - Needs patch
  apt:sid:hat
    - Needs patch
  gtkrsync
    - depends on gtk2hs
  arch2darcs
    - depends on missingh
  darcs-buildpackage
    - depends on missingh and haskell-configfile
  dfsbuild
    - depends on missingh, haskell-configfile, haskell-hsh
  hg-buildpackage
    - depends on ???
  srcinst
    - depends on ???
  deb-dir:(darcs:http://code.haskell.org/vector-space):(darcs:http://src.seereason.com/debian/vector-space-debian)
    - broken
  apt:sid:ghc-cvs
    - broken
  apt:sid:haskell98-report
    - broken
  quilt:(apt:sid:hdbc):(darcs:http://src.seereason.com/quilt/hdbc-quilt)
    - broken
  apt:sid:hdbc-odbc
    - broken
  apt:sid:hdbc-postgresql
    - broken
  apt:sid:hdbc-sqlite3
    - broken
  apt:sid:hpodder
    - broken
  quilt:(darcs:http://code.haskell.org/encoding):(darcs:file:///home/david/darcs/haskell-encoding)
    - Patches won't apply:
  apt:sid:hdbc-missingh
    - Depends on ghc6 (<< 6.6+) or (<< 6.6-999)
  apt:sid:kaya
    - Error parsing build depends (unexpected #):
  apt:sid:missingpy
    - Disabled due to flaw in the autobuilder's build dependency parser:
  sourcedeb:tla:dsf@foxthompson.net--2004/haskell-binary--dsf--0.3.0
  tla:dsf@foxthompson.net--2004/hxt--dsf--7.0
  sourcedeb:tla:dsf@foxthompson.net--2004/cpphs--dsf--1.3
  quilt:(apt:feisty:haskell-http):(tla:dsf@foxthompson.net--2004/haskell-http-quilt--dsf--0)
  sourcedeb:tla:dsf@foxthompson.net--2004/yhc--dsf--0.7.0
Name: kernel-targets
Targets:
  apt:gutsy:linux-source-2.6.22
  apt:gutsy:linux-meta
  quilt:(apt:gutsy:linux-restricted-modules-2.6.22):(tla:tos@linspire.com--skipjack/linux-restricted-modules-quilt--ubuntu--0)
Comment: Here are some more proposed targets
  tla:tos@linspire.com--skipjack/forward-oss-kernel-module--cnr--20070605
  tla:tos@linspire.com--skipjack/forward-oss--build-skipjack--0.3
  quilt:(apt:${base}:bcm43xx-fwcutter):(tla:tos@linspire.com--skipjack/bcm43xx-fwcutter-quilt--cnr--0)
-}
