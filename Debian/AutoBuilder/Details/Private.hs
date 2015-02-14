{-# LANGUAGE OverloadedStrings, PackageImports, TemplateHaskell #-}
{-# OPTIONS -Wall -fno-warn-missing-signatures #-}
module Debian.AutoBuilder.Details.Private (libraries, applications) where

import Data.FileEmbed (embedFile)
import Debian.AutoBuilder.Types.Packages as P (Packages(APackage), PackageFlag(BuildDep, CabalDebian, NoDoc), flag, patch, debianize, darcs, git, cd)
import Debian.AutoBuilder.Details.Common (privateRepo, named, ghcjs_flags)
import Debian.Repo.Fingerprint (GitSpec(Branch))
import System.FilePath ((</>))

libraries _home =
    named "libraries" $ map APackage $
    [ -- Retired, should be withdrawn from repos
      -- darcs "haskell-generic-formlets3" (privateRepo </> "generic-formlets3")
    -- , darcs "haskell-document" (privateRepo </> "haskell-document")
      git "ssh://git@github.com/seereason/ontology.git" []
    , debianize (git "https://github.com/stepcut/stripe-haskell" [Branch "stripe-has-param"]
                   `cd` "stripe-core")
    , debianize (git "https://github.com/stepcut/stripe-haskell" [Branch "stripe-has-param"]
                   `cd` "stripe-http-streams")
    -- , debianize (darcs (privateRepo </> "stripe") `cd` "stripe-http-conduit")
    , debianize (darcs (privateRepo </> "clckwrks-plugin-stripe")
                   `flag` P.BuildDep "hsx2hs")
    -- The debian/Debianize.hs script has a dependency on
    -- happstack-foundation, which must be installed in the parent
    -- environment *before* we can create the debianization.  We don't
    -- really have a mechanism to ensure this is installed in the
    -- parent environment, except making it a dependency of the
    -- autobuilder itself.
    , debianize (git "ssh://git@github.com/seereason/mimo.git" [])
    , debianize (git "ssh://git@github.com/seereason/task-manager.git" [])
    , debianize (darcs (privateRepo </> "happstack-ghcjs") `cd` "happstack-ghcjs-client"
                   `flag` P.BuildDep "libghc-cabal-ghcjs-dev"
                   `flag` P.BuildDep "ghcjs"
                   `flag` P.BuildDep "haskell-devscripts (>= 0.8.21.3)"
                   `flag` P.CabalDebian ["--ghcjs", "--source-package=ghcjs-happstack-ghcjs-client"])
    , debianize (darcs (privateRepo </> "happstack-ghcjs") `cd` "happstack-ghcjs-server")
    , debianize (darcs (privateRepo </> "happstack-ghcjs") `cd` "happstack-ghcjs-webmodule") -- for GHC
    , ghcjs_flags $
      debianize (darcs (privateRepo </> "happstack-ghcjs") `cd` "happstack-ghcjs-webmodule") -- for GHCJS

    ] {- ++ clckwrks14 -}

applications _home =
    named "applications" $ map APackage $
    [ debianize (git "ssh://git@github.com/seereason/appraisalscribe" [])
    , debianize (git "ssh://git@github.com/seereason/appraisalscribe-data" [])

    -- appraisalscribe-data-tests is a huge package because it
    -- contains lots of test data, it makes more sense to just check
    -- it out of git and run it rather than constantly uploading it to
    -- the repository.
    -- , debianize (git "ssh://git@github.com/seereason/appraisalscribe-data-tests" [])

    , debianize (git "https://github.com/seereason/image-cache.git" [])
    , git "ssh://git@github.com/seereason/seereason" []
    , debianize (git "ssh://git@github.com/seereason/happstack-ontology" []
                   `flag` P.BuildDep "hsx2hs")
    -- Obsolete
    -- , darcs "haskell-creativeprompts" (privateRepo </> "creativeprompts")
    -- There is a debianization in the repo that contains this file
    -- (Targets.hs), and it creates a package named seereason-darcs-backups,
    -- which performs backups on the darcs repo.
    , debianize (darcs (privateRepo </> "seereasonpartners-clckwrks")
                   `cd` "seereasonpartners-dot-com"
                   `patch` $(embedFile "patches/seereasonpartners-dot-com.diff"))
    , debianize (darcs (privateRepo </> "seereasonpartners-clckwrks")
                   `cd` "clckwrks-theme-seereasonpartners"
                   `flag` P.BuildDep "hsx2hs"
                   `flag` P.NoDoc)
    , debianize (darcs (privateRepo </> "clckwrks-theme-appraisalscribe")
                   `flag` P.BuildDep "hsx2hs")
    ]

