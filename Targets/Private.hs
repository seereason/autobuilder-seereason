{-# OPTIONS -Wall -fno-warn-missing-signatures #-}
module Targets.Private (libraries, applications) where

import Data.List (intercalate)
import Data.Set (singleton)
import qualified Debian.AutoBuilder.Types.Packages as P
import Debian.AutoBuilder.Types.Packages
import Targets.Common

libraries _home =
    P.Packages (singleton "libraries") $
    [ P.Package { P.name = "haskell-document"
                , P.spec = Darcs (privateRepo ++ "/haskell-document")
                , P.flags = [] }
    , P.Package { P.name = "haskell-generic-formlets3"
                , P.spec = Darcs (privateRepo ++ "/generic-formlets3")
                , P.flags = [] }
    , P.Package { P.name = "haskell-ontology"
                , P.spec = Darcs (privateRepo ++ "/haskell-ontology")
                , P.flags = [] }
    ]

applications _home =
    P.Packages (singleton "applications") $
    [ P.Package { P.name = "haskell-artvaluereport"
                , P.spec = Darcs (privateRepo ++ "/artvaluereport")
                , P.flags = [] }
    , P.Package { P.name = "haskell-artvaluereport2"
                , P.spec = Darcs (privateRepo ++ "/artvaluereport2")
                , P.flags = [] }
    , P.Package { P.name = "haskell-artvaluereport-data"
                , P.spec = Darcs (privateRepo ++ "/artvaluereport-data")
                , P.flags = [] }
{-  , P.Package { P.name = "haskell-happstack-mailinglist"
                , P.spec = Darcs (privateRepo ++ "/mailingList")
                , P.flags = [] } -}
    , P.Package { P.name = "haskell-seereason"
                , P.spec = Darcs (privateRepo ++ "/seereason")
                , P.flags = [] }
    , P.Package { P.name = "haskell-happstack-ontology"
                , P.spec = Darcs (privateRepo ++ "/happstack-ontology")
                , P.flags = [] }
    , P.Package { P.name = "haskell-creativeprompts"
                , P.spec = Darcs (privateRepo ++ "/creativeprompts")
                , P.flags = [] }
{-
    , P.Package { P.name = "prefeteria"
                , P.spec = Darcs (privateRepo ++ "/prefeteria") []
                , P.flags = [] }
-}
    -- There is a debianization in the repo that contains this file
    -- (Targets.hs), and it creates a package named seereason-darcs-backups,
    -- which performs backups on the darcs repo.
    , P.Package { P.name = "seereason-darcs-backups"
                , P.spec = Darcs "http://src.seereason.com/autobuilder-config"
                , P.flags = [] }
    , P.Package { P.name = "clcksmith"
                , P.spec = Darcs (privateRepo ++ "/clcksmith")
                , P.flags = [P.CabalDebian ["--build-dep", "haskell-hsx-utils"],
                             P.CabalDebian
                                 ["--depends",
                                  (intercalate ","
                                        (map ("clcksmith-server:"++)
                                                ["markdown",
                                                 "poppler-utils",
                                                 "haskell-clckwrks-theme-clcksmith-utils",
                                                 "haskell-clckwrks-utils",
                                                 "ghc", "ghc-prof",
                                                 "libghc-network-prof",
                                                 "libghc-applicative-extras-prof",
                                                 "libghc-clckwrks-prof",
                                                 "libghc-clckwrks-plugin-media-prof",
                                                 "libghc-clckwrks-theme-clcksmith-prof",
                                                 "libghc-data-lens-prof",
                                                 "libghc-haskell-src-exts-prof",
                                                 "libghc-haskell-src-meta-prof",
                                                 "libghc-hdaemonize-prof",
                                                 "libghc-hslogger-prof",
                                                 "libghc-hsyslog-prof",
                                                 "libghc-multiset-prof",
                                                 "libghc-plugins-auto-prof",
                                                 "libghc-regex-compat-prof",
                                                 "libghc-syb-prof",
                                                 "libghc-web-routes-prof",
                                                 "libghc-web-routes-happstack-prof",
                                                 "libghc-web-routes-th-prof"]))]] }
    , P.Package { P.name = "clckwrks-theme-clcksmith"
                , P.spec = Debianize (Cd "clckwrks-theme-clcksmith" (Darcs (privateRepo ++ "/clcksmith")))
                -- Haddock gets upset about the HSX.QQ modules.  Not sure why.
                , P.flags = [P.CabalDebian ["--build-dep", "haskell-hsx-utils", "--disable-haddock", "--deb-version", "0.1-1~hackage1"]] }
    , P.Package { P.name = "seereasonpartners-dot-com"
                , P.spec = Cd "seereasonpartners-dot-com" (Darcs (privateRepo ++ "/seereasonpartners-clckwrks"))
                , P.flags = [] }
    , P.Package { P.name = "haskell-clckwrks-theme-seereasonpartners"
                , P.spec = Debianize (Cd "clckwrks-theme-seereasonpartners" (Darcs (privateRepo ++ "/seereasonpartners-clckwrks")))
                , P.flags = [P.CabalDebian ["--build-dep", "haskell-hsx-utils", "--disable-haddock"]] }
    , P.Package { P.name = "appraisalreportonline-dot-com"
                , P.spec = Cd "appraisalreportonline-dot-com" (Darcs (privateRepo ++ "/appraisalreportonline-clckwrks"))
                , P.flags = [] }
    , P.Package { P.name = "haskell-clckwrks-theme-appraisalreportonline"
                , P.spec = Debianize (Cd "clckwrks-theme-appraisalreportonline" (Darcs (privateRepo ++ "/appraisalreportonline-clckwrks")))
                , P.flags = [P.CabalDebian ["--build-dep", "haskell-hsx-utils"]] }
    ]
