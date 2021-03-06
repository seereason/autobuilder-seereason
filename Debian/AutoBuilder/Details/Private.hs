{-# LANGUAGE OverloadedStrings, PackageImports, TemplateHaskell #-}
{-# OPTIONS -Wall -fno-warn-missing-signatures #-}
module Debian.AutoBuilder.Details.Private (buildTargets) where

--import Control.Lens (use)
import Data.FileEmbed (embedFile)
--import Data.Map as Map (keys)
import Debian.Repo.Fingerprint (GitSpec(Branch))
import Debian.AutoBuilder.Types.Packages as P (PackageFlag(BuildDep, CabalDebian {-, NoDoc, SetupDep-}), flag, patch, debianize, git, cd, inGroups{-, dir, -packageMap, hackage-})
import Debian.AutoBuilder.Types.ParamRec (ParamRec)
import Debian.AutoBuilder.Details.Common -- (privateRepo, named, ghcjs_flags)
--import Debian.Repo.Fingerprint (GitSpec(Branch, Commit))
--import System.FilePath ((</>))

-- Individual packages, alphabetized

buildTargets :: Monad m => ParamRec -> TSt m ()
buildTargets _params = do
  -- _appraisalscribe <- git "ssh://git@github.com/seereason/appraisalscribe" [] >>= flag (P.CabalDebian ["--disable-profiling"]) >>= debianize []
  _appraisalscribe_data <- git "ssh://git@github.com/seereason/appraisalscribe-data" [{-Branch "dsf"-}] >>= {- flag (P.CabalDebian ["--disable-profiling"]) >>= -} debianize [] >>= ghcjs_also
  -- appraisalscribe-data-tests is a huge package because it
  -- contains lots of test data, it makes more sense to just check
  -- it out of git and run it rather than constantly uploading it to
  -- the repository.
  -- appraisalscribe_data_tests = debianize (git "ssh://git@github.com/seereason/appraisalscribe-data-tests" [])

  _clckwrks_plugin_stripe <- git "ssh://git@github.com/seereason/clckwrks-plugin-stripe" [] >>= {-patch $(embedFile "patches/clckwrks-plugin-stripe-locktag.diff") >>=-} flag (P.BuildDep "hsx2hs") >>= debianize [] >>= inGroups ["private-libs"]
  _clckwrks_theme_seereasonpartners <-
      git "ssh://git@github.com/seereason/seereasonpartners-clckwrks" [] >>=
      cd "clckwrks-theme-seereasonpartners" >>=
      flag (P.BuildDep "hsx2hs") >>=
      debianize []
  _clckwrks_theme_appraisalscribe <- git "ssh://git@github.com/seereason/clckwrks-theme-appraisalscribe" [] >>= flag (P.BuildDep "hsx2hs") >>= debianize []

  _editor_common <- git "ssh://git@github.com/seereason/editor-common" [{-Commit "f00100c09e59e754c995feefe648a837fcc22bad"-}] >>= debianize [] >>= ghcjs_also
  _editor_client <- git "ssh://git@github.com/seereason/editor-client" [{-Commit "1437da05a7e1574529094869b7d2a3741c6dfec0"-}] >>= debianize [] >>= ghcjs_only
  _editor_server <- git "ssh://git@github.com/seereason/editor-server" [{-Commit "d64b1e8e55bde3ee97ceaf6c4558c1b8868dc2e7"-}] >>= debianize []
  _editor_taggy <- git "ssh://git@github.com/seereason/editor-taggy" [{-Commit "73214999dbacd5245d7eccdf0e5b9f64a644fb23"-}] >>= debianize [] >>= ghcjs_also

  let happstack_ghcjs = git "ssh://git@github.com/seereason/happstack-ghcjs" [{-Branch "dsf"-} ] {-dir "/home/dsf/git/happstack-ghcjs"-}
  _happstack_ghcjs_client <- happstack_ghcjs >>= cd "happstack-ghcjs-client" >>= debianize [] >>= inGroups ["private-libs"] >>= ghcjs_only
  _happstack_ghcjs_common <- happstack_ghcjs >>= cd "happstack-ghcjs-common" >>= debianize [] >>= flag (P.CabalDebian ["--disable-profiling"]) >>= inGroups ["private-libs"] >>= ghcjs_also
  _happstack_ghcjs_server <- happstack_ghcjs >>= cd "happstack-ghcjs-server" >>= debianize [] >>= flag (P.CabalDebian ["--disable-profiling"]) >>= inGroups ["private-libs"]
  _happstack_ghcjs_webmodule <- happstack_ghcjs >>= cd "happstack-ghcjs-webmodule" >>= flag (P.BuildDep "haskell-editor-common-utils") >>= debianize [] >>= flag (P.CabalDebian ["--disable-profiling"]) >>= inGroups ["private-libs"] >>= ghcjs_also

  _happstack_ontology <- git "ssh://git@github.com/seereason/happstack-ontology" [] >>= flag (P.BuildDep "hsx2hs") >>= debianize []
  _image_cache <- git "https://github.com/seereason/image-cache.git" [] >>= {-patch $(embedFile "patches/image-cache-locktag.diff") >>=-} {- flag (P.CabalDebian ["--disable-profiling"]) >>= -} debianize [] >>= ghcjs_also
  -- The debian/Debianize.hs script has a dependency on
  -- happstack-foundation, which must be installed in the parent
  -- environment *before* we can create the debianization.  We don't
  -- really have a mechanism to ensure this is installed in the parent
  -- environment, except making it a dependency of the autobuilder
  -- itself.
  -- _mimo <- git "ssh://git@github.com/seereason/mimo.git" [] >>= debianize [] >>= inGroups ["private-libs"]
  -- These won't build unless libghc-mimo-dev is installed.  Unfortunately,
  -- when mimo's dependencies change the library often gets uninstalled.
{-
  _mimo_bootstrap <-
      git "ssh://git@github.com/seereason/mimo-bootstrap.git" [] >>=
          flag (P.SetupDep "libghc-mimo-dev") >>=
          flag (P.BuildDep "haskell-mimo-utils") >>=
          debianize [] >>= inGroups ["private-libs"]
  _mimo_optimum <-
      git "ssh://git@github.com/seereason/mimo-optimum.git" [] >>=
          flag (P.SetupDep "libghc-mimo-dev") >>=
          flag (P.BuildDep "haskell-mimo-utils") >>=
          debianize [] >>= inGroups ["private-libs"]
  _mimo_paste <-
      git "ssh://git@github.com/seereason/mimo-paste.git" [] >>=
          flag (P.SetupDep "libghc-mimo-dev") >>=
          flag (P.BuildDep "haskell-mimo-utils") >>=
          debianize [] >>= inGroups ["private-libs"]
-}

  _ontology <- git "ssh://git@github.com/seereason/ontology.git" [] >>= debianize [] >>= inGroups ["private-libs"]
  _seereason <- git "ssh://git@github.com/seereason/seereason" [] >>= debianize []
  _seereasonpartners_dot_com <-
      git "ssh://git@github.com/seereason/seereasonpartners-clckwrks" [] >>=
      cd "seereasonpartners-dot-com" >>=
      patch $(embedFile "patches/seereasonpartners-dot-com.diff") >>=
      debianize []
  -- let stripeRepo = "https://github.com/seereason/stripe"
  let stripeRepo = "https://github.com/dmjio/stripe"
  _stripe_http_client <- git stripeRepo [] >>= cd "stripe-http-client" {-hackage (Just "2.4.0") "stripe-http-client"-} >>= debianize []
  _stripe_core <- git stripeRepo [] >>= cd "stripe-core" >>= debianize [] >>= inGroups ["private-libs"]
  _stripe_http_streams <- git stripeRepo [] >>= cd "stripe-http-streams" >>= flag (P.CabalDebian ["--no-tests"]) >>=  debianize [] >>= inGroups ["private-libs"]
  _stripe_haskell <- git stripeRepo [] >>= cd "stripe-haskell" >>= flag (P.CabalDebian ["--no-tests"]) >>= debianize []
  -- stripe_http_conduit <- debianize (darcs (privateRepo </> "stripe") `cd` "stripe-http-conduit")
  _task_manager <- git "ssh://git@github.com/seereason/task-manager.git" [] >>= debianize [] >>= inGroups ["private-libs"]
  -- why --disable-profiling?
  _typegraph <- git "ssh://git@github.com/seereason/typegraph.git" [{-Branch "dsf"-}] >>= debianize [] >>= inGroups ["private-libs"] >>= {- flag (P.CabalDebian ["--disable-profiling"]) >>= -} ghcjs_also
  _history <- git "ssh://git@github.com/seereason/history.git" [{-Branch "dsf"-}] >>= debianize [] >>= inGroups ["private-libs"] >>= {- flag (P.CabalDebian ["--disable-profiling"]) >>= -} ghcjs_also
  _history_tests <- git "ssh://git@github.com/seereason/history-tests.git" [{-Branch "dsf"-}] >>= debianize [] >>= inGroups ["private-libs"]
  noTests
  -- noDoc
  -- noProf

{-
libraries :: Monad m => TSt m ()
libraries =
    -- (named "libraries") =<<
    sequence
    [ ontology
    , stripe_core
    , stripe_http_streams
    , clckwrks_plugin_stripe
    , mimo
    , mimo_bootstrap
    , mimo_optimum
    , mimo_paste
    , th_path
    , th_path >>= ghcjs_flags
    , task_manager
    , happstack_ghcjs_client
    , happstack_ghcjs_server
    , happstack_ghcjs_webmodule
    , ghcjs_ghcjs_webmodule
    ] >> noTests

applications :: Monad m => TSt m ()
applications =
    -- (named "applications") =<<
    sequence
    [ appraisalscribe
    , appraisalscribe_data
    , appraisalscribe_data >>= ghcjs_flags >>= flag P.NoDoc
    , image_cache
    , image_cache >>= ghcjs_flags
    , seereason
    , happstack_ontology
    , seereasonpartners_dot_com
    , clckwrks_theme_seereasonpartners
    , clckwrks_theme_appraisalscribe
    ] >> noTests
-}
