-- THIS FILE IS WHERE YOU DO ALL THE CUSTOMIZATIONS REQUIRED FOR THE
-- REPOSTORIES YOU ARE BUILDING.  The Targets.hs file may also be
-- modified to reflect the sources for the packages you will be
-- building.  If you find yourself modifying other files I would like
-- to hear about it.

{-# OPTIONS -Wall -fno-warn-missing-signatures #-}
module Debian.AutoBuilder.Details
    ( myParams
    ) where

import Data.Maybe
import Data.Monoid (mappend)
-- import Data.Set as Set (Set, empty)
import Debian.AutoBuilder.Details.Sources (myUploadURI, myBuildURI, myReleaseAliases, releaseRepoName, mySources)
import qualified Debian.AutoBuilder.Types.Packages as P
import Debian.AutoBuilder.Types.DefaultParams (defaultParams)
import Debian.AutoBuilder.Types.Packages (Packages(NoPackage))
import Debian.AutoBuilder.Types.ParamRec (ParamRec(..))
import Debian.Releases (Release(..), BaseRelease(..),
                        releaseString, parseReleaseName, isPrivateRelease,
                        baseRelease, Distro(..))
import Debian.Repo.Slice (Slice, PPASlice(PersonalPackageArchive, ppaUser, ppaName))
import Debian.Version (parseDebianVersion)
import qualified Debian.AutoBuilder.Details.Targets as Targets
import Prelude hiding (map)

myParams :: FilePath -> Release -> ParamRec
myParams home myBuildRelease =
    let myUploadURIPrefix = "ssh://upload@deb.seereason.com/srv"
        myBuildURIPrefix = "http://deb.seereason.com" in
    (\ params -> params {knownPackages = myKnownTargets home params}) $
    (defaultParams (releaseString myBuildRelease)
                   myUploadURIPrefix
                   myBuildURIPrefix
                   myDevelopmentReleaseNames)
    { vendorTag = myVendorTag
    , oldVendorTags = ["seereason"]
    , autobuilderEmail = "SeeReason Autobuilder <partners@seereason.com>"
    , releaseSuffixes = myReleaseSuffixes
    , extraRepos = myExtraRepos
    , uploadURI = myUploadURI myBuildRelease
    , buildURI = myBuildURI myBuildRelease
    , sources = mySources myBuildRelease
    , globalRelaxInfo = myGlobalRelaxInfo
    , includePackages = myIncludePackages myBuildRelease
    , optionalIncludePackages = myOptionalIncludePackages myBuildRelease
    , excludePackages = myExcludePackages myBuildRelease
    , components = myComponents myBuildRelease
    , developmentReleaseNames = myDevelopmentReleaseNames
    , releaseAliases = myReleaseAliases myBuildRelease
    , newDistProgram = "newdist --sender-email=autobuilder@seereason.com --notify-email dsf@seereason.com --notify-email beshers@seereason.com --notify-email jeremy@seereason.com"
    -- 6.14 adds the ExtraDevDep parameter.
    -- 6.15 changes Epoch parameter arity to 2
    -- 6.18 renames type Spec -> RetrieveMethod
    -- 6.35 added the CabalDebian flag
    -- 6.64 removes the myCompilerVersion argument from defaultParams
    , requiredVersion = [(parseDebianVersion ("6.64" :: String), Nothing)]
    , hackageServer = myHackageServer
    }

-- https://launchpad.net/~hvr/+archive/ubuntu/ghc
myExtraRepos :: [Either Slice PPASlice]
myExtraRepos = [{-Right (PersonalPackageArchive {ppaUser = "hvr", ppaName = "ghc"})-}]

-- This section has all the definitions relating to the particular
-- suffixes we will use on our build releases.
--
myReleaseSuffixes = ["-seereason", "-private"]

--
-- End of release suffix section.

-- The current list of development releases.  The version numbers for
-- these releases do not need to be tagged with the base release name,
-- only with the vendor tag.  Sid is always a development release,
-- Ubuntu creates a new one for each cycle.
--
myDevelopmentReleaseNames = ["sid", "quantal"]

-- This tag is used to construct the customized part of the version
-- number for any package the autobuilder builds.
--
myVendorTag = "+seereason"

--myDiscards :: Set.Set String
--myDiscards = Set.empty

-- The set of all known package targets.  The targets we will
-- actually build are chosen from these.  The myBuildRelease argument
-- comes from the autobuilder argument list.
--
myKnownTargets :: FilePath -> ParamRec -> P.Packages
myKnownTargets home params =
    if isPrivateRelease rel
    then Targets.private home rel
    else mappend (Targets.public home rel) (if testWithPrivate params then Targets.private home rel else NoPackage)
    where
      rel = parseReleaseName (buildRelease params)

-- Additional packages to include in the clean build environment.
-- Adding packages here can speed things up when you are building many
-- packages, because for each package it reverts the build environment
-- to the clean environment and then installs all the build
-- dependencies.  This only affects newly created environments, so if
-- you change this value use the flushRoot option to get it to take
-- effect.
--
-- Note that these packages must exist and be valid at the time the
-- environment is created.  If there is a package that you want in the
-- clean environment that isn't available in the base repository (e.g.
-- seereason-keyring) you currently need to first build it and then
-- install it manually.
--
myIncludePackages :: Release -> [String]
myIncludePackages myBuildRelease =
    [ "debian-archive-keyring"
    , "build-essential"         -- This is required by autobuilder code that opens the essential-packages list
    , "pkg-config"              -- Some packages now depend on this package via new cabal options.
    , "debian-keyring"
    , "locales"
    , "software-properties-common" -- Required to run add-apt-repository to use a PPA.
    -- , "autobuilder-seereason"   -- This pulls in dependencies required for some pre-build tasks, e.g. libghc-cabal-debian-dev
    -- , "perl-base"
    -- , "gnupg"
    -- , "dpkg"
    -- , "locales"
    -- , "language-pack-en"
    -- , "ghc6"
    -- , "ghc6-doc"
    -- , "ghc6-prof"
    -- , "makedev"
    ] ++
    -- Private releases generally have ssh URIs in their sources.list,
    -- I have observed that this solves the "ssh died unexpectedly"
    -- errors.
    (if isPrivateRelease myBuildRelease then ["ssh"] else []) ++
    case releaseRepoName (baseRelease myBuildRelease) of
      Debian -> []
      Ubuntu ->
          ["ubuntu-keyring"] ++
          case baseRelease myBuildRelease of
            Trusty -> []
            Saucy -> []
            Raring -> []
            Quantal -> []
            Precise -> []
            Oneiric -> []
            Natty -> []
            Maverick -> []
            Lucid -> []
            Karmic -> [{-"upstart"-}]
            Jaunty -> [{-"upstart-compat-sysv"-}]
            Intrepid -> [{-"upstart-compat-sysv", "belocs-locales-bin"-}]
            Hardy -> [{-"upstart-compat-sysv", "belocs-locales-bin"-}]
            _ -> [{-"belocs-locales-bin"-}]
      _ -> error $ "Invalid base distro: " ++ show myBuildRelease

-- This will not be available when a new release is created, so we
-- have to make due until it gets built and uploaded.
myOptionalIncludePackages _myBuildRelease =
    [ "seereason-keyring" ]

myExcludePackages _ = []

myComponents :: Release -> [String]
myComponents myBuildRelease =
    case releaseRepoName (baseRelease myBuildRelease) of
      Debian -> ["main", "contrib", "non-free"]
      Ubuntu -> ["main", "restricted", "universe", "multiverse"]
      _ -> error $ "Invalid base distro: " ++ show myBuildRelease

myHackageServer = "hackage.haskell.org"
-- myHackageServer = "hackage.factisresearch.com"

-- Any package listed here will not trigger rebuilds when updated.
--
myGlobalRelaxInfo =
    ["base-files",
     "bash",
     "bsdutils",
     "cdbs",
     "devscripts",
     "dpkg",
     "dpkg-dev",
     "gcc",
     "g++",
     "libc-bin",
     "make",
     "mount",
     "base-passwd",
     "mktemp",
     "sed",
     "util-linux",
     "sysvinit-utils",
     "autoconf",
     "debhelper",
     "debianutils",
     "diff",
     "e2fsprogs",
     "findutils",
     "flex",
     "login",
     "coreutils",
     "grep",
     "gs",
     "gzip",
     "hostname",
     "intltool",
     "ncurses-base",
     "ncurses-bin",
     "perl",
     "perl-base",
     "python-minimal",
     "tar",
     "sysvinit",
     "libc6-dev",
     "haskell-devscripts"]
