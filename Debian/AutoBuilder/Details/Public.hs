{-# LANGUAGE CPP, MultiWayIf, OverloadedStrings, RecordWildCards, TemplateHaskell #-}
{-# OPTIONS -Wall -fno-warn-missing-signatures -fno-warn-unused-binds -fno-warn-name-shadowing #-}
module Debian.AutoBuilder.Details.Public ( targets ) where

import OldLens hiding ((~=), lens)

import Control.Applicative ((<$>), pure)
import Control.Monad.State (get)
import Data.FileEmbed (embedFile)
import Data.Set as Set (insert)
import Data.Text as Text (unlines)
import Debian.AutoBuilder.Details.Common -- (named, ghcjs_flags, putSrcPkgName)
import Debian.AutoBuilder.Types.Packages as P (TSt, TargetState(release), mapPackages,
                                               PackageFlag(CabalPin, DevelDep, DebVersion, BuildDep, CabalDebian, RelaxDep, Revision, Maintainer,
                                                           ModifyAtoms, UDeb, OmitLTDeps, SkipVersion, KeepRCS),
                                               Packages(..), Package(..), flags, spec, hackage, debianize, flag, patch, darcs, apt, git, cd, proc, debdir)
import Debian.Debianize as D
    (compat, doExecutable, execCabalM, rulesFragments, InstallFile(..), (+=), (~=), debInfo, atomSet, Atom(InstallData))
import Debian.Relation (BinPkgName(..))
import Debian.Releases (baseRelease, BaseRelease(..))
import Debian.Repo.Fingerprint (RetrieveMethod(Uri, DataFiles, Patch, Darcs, Debianize'', Hackage, DebDir, Git), GitSpec(Commit, Branch))

--------------------
-- PACKAGE GROUPS --
--------------------

noTests :: TSt Packages -> TSt Packages
noTests = mapPackages (\ p -> p `flag` P.CabalDebian ["--no-tests"])

-- |the _home parameter has an underscore because normally it is unused, but when
-- we need to build from a local darcs repo we use @localRepo _home@ to compute
-- the repo location.
targets :: TSt P.Packages
targets =
    noTests $
    named "all" =<<
    sequence
    [ new
    , main
    , autobuilder_group
    , clckwrks_group
    , sunroof
    , haste
    , darcs_group
    , ghcjs_group
    , idris_group
    -- , authenticate
    -- , happstackdotcom
    -- , happstack release
    , digestive_functors_group
     , algebra
    -- , units_group
    -- , diagrams
    , fixme
    -- , higgsset
    -- , jsonb
    -- , glib
    -- , plugins_group
    -- , frisby
    -- , failing
    -- , agda
    -- , other
    ]

fixme :: TSt P.Packages
fixme =
    (named "fixme" . map APackage) =<<
    sequence
    [ test_framework_smallcheck
    , genI
    ]

autobuilder_group :: TSt P.Packages
autobuilder_group =
    named "autobuilder-group" =<< (sequence [unixutils_group, libs])
    where
      libs = (Packages . map APackage) <$>
             sequence
             [ debian_haskell
             , cabal_debian
             , mirror
             , debian_repo
             , autobuilder
             , archive
             , process_extras
             , filemanip_extra
             , autobuilder_seereason ]

unixutils_group :: TSt P.Packages
unixutils_group = (named "Unixutils" . map APackage) =<< sequence [unixutils, haskell_extra, haskell_help]

-- Stick new packages here to get an initial build, then move
-- them to a suitable group.
new :: TSt P.Packages
new = (named "new" . map APackage) =<<
      sequence
      [ aeson_pretty
      , appar
      , atomic_primops
      , auto_update
      , data_r_tree
      , data_stringmap
      , easy_file
      , ekg_core
      , fast_logger
      , file_location
      , hamlet
      , http_date
      -- , hunt -- depends on text << 1.2
      , iproute
      , monad_parallel
      , pseudomacros
      , scotty
      , shakespeare
      , shakespeare_js
      , showplease
      , simple_sendfile
      , spine
      , wai_extra
      , wai_logger
      , wai_middleware_static
      , warp ]

main :: TSt P.Packages
main =
    Packages <$> sequence [compiler, platform, main]
    where
      main :: TSt P.Packages
      main = (named "main" . map APackage) =<<
             sequence
             [ abstract_deque
             , abstract_par
             , aeson
             , agi
             , ansi_terminal
             , ansi_wl_pprint
             , applicative_extras
             , asn1_data
             , asn1_types
             , async
             , attempt
             , attoparsec
             , attoparsec_enumerator
             , base16_bytestring
             , base_unicode_symbols
             , bimap
             , bitmap
             , bits_atomic
             , bitset
             , boomerang
             , bugzilla
             , byteable
             , byteorder
             , bytes
             , bytestring_builder
             , bytestring_nums
             , bytestring_trie
             , bzlib
             , cabal_macosx
             , case_insensitive
             , cautious_file
             , cc_delcont
             , cereal
             , charset
             , charsetdetect_ae
             , cipher_aes
             , cipher_des
             , citeproc_hs
             , clock
             , closure_compiler
             , cmdargs
             , colour
             , concatenative
             , concrete_typerep
             , cond
             , configFile
             , consumer
             , cookie
             , cpphs
             , cprng_aes
             , cpu
             , crypto
             , crypto_api
             , cryptohash
             , crypto_pubkey_types
             , crypto_random
             , crypto_random_api
             , css
             , css_text
             , csv
             , curl
             , currency
             , data_accessor
             , data_accessor_template
             , data_default
             , data_default_class
             , data_default_instances_base
             , data_default_instances_containers
             , data_default_instances_dlist
             , data_default_instances_old_locale
             , dataenc
             , data_object
             , data_ordlist
             , datetime
             , debootstrap
             , decimal
             , deepseq_generics
             , derive
             , diff
             , digest
             , directory_tree
             , dlist
             , double_conversion
             , dynamic_state
             , dyre
             , edisonAPI
             , edisonCore
             , haskell_either
             , entropy
             , enumerator
             , erf
             , errors
             , exceptions
             , executable_path
             , extensible_exceptions
             , extra
             , failure
             , feed
             , file_embed
             , filemanip
             , fmlist
             , formlets
             , frquotes
             , gd
             , gdiff
             , generic_deriving
             , ghc_mtl
             , ghc_paths
             , groom
             , gtk2hs_buildtools
             , harp
             , hashable
             , hashed_storage
             , hashtables
             , haskeline
             , haskell_devscripts
             , haskell_lexer
             , haskell_newtype
             , haskell_revision
             , haskell_src_exts
             , haskell_src_meta
             , haTeX
             , haXml
             , hdaemonize
             , heap
             , hexpat
             , hinotify
             -- , hint -- failing
             , hJavaScript
             , hledger
             , mtl_compat
             , hostname
             , hourglass
             , hpdf
             , hS3
             , hs_bibutils
             , hscolour
             , hsemail
             , hslogger
             , hsOpenSSL
             , hspec
             , hspec_core
             , hspec_discover
             , hspec_expectations
             , hspec_meta
             , hsSyck
             , hStringTemplate
             , hsyslog
             , htf
             , html_entities
             , html_xml_utils
             , http_types
             , hxt
             , hxt_charproperties
             , hxt_regex_xmlschema
             , hxt_unicode
             -- , i18n -- failing
             , iconv
             , incremental_sat_solver
             , indents
             , instant_generics
             , ioRefCAS
             , io_storage
             , irc
             , iso3166_country_codes
             , ixset
             , jquery
             , jquery_goodies
             , jqueryui18
             , js_flot
             , js_jquery
             , json
             , kan_extensions
             , language_css
             , language_ecmascript
             , language_haskell_extract
             , language_javascript
             , largeword
             , latex
             , libjs_jcrop
             , lifted_base
             , haskell_list
             , list_extras
             , listLike
             , loch_th
             , logic_classes
             , logict
             , logic_TPTP
             , loop
             , lucid
             , maccatcher
             , magic
             , markdown_unlit
             , matrix
             , maybeT
             , memoize
             , mime
             , missingH
             , mmap
             , module_management
             , monadCatchIO_mtl
             , monadCatchIO_transformers
             , monad_control
             , monadLib
             , monad_par
             , monad_par_extras
             , monadRandom
             , monads_tf
             , monoid_transformer
             , mtlparse
             , multiset
             , murmur_hash
             , mwc_random
             , nano_hmac
             , nanospec
             , nats
             , network_info
             , network_uri
             , oo_prototypes
             , openid
             , operational
             , optparse_applicative
             , ordered
             , pandoc_types
             , parseargs
             , parse_dimacs
             , pbkdf2
             , pcre_light
             , permutation
             , pipes
             , placeholders
             , pointed
             , pointedlist
             , polyparse
             , pretty_show
             , primitive
             , propLogic
             , psQueue
             , pwstore_purehaskell
             -- , quickcheck_gent -- depends on quickcheck << 2.7
             , quickcheck_io
             , regex_compat_tdfa
             , regex_pcre_builtin
             , regexpr
             , regex_tdfa
             , regex_tdfa_rc
             -- , rJson -- we don't use this, it doesn't build, has no rcs url, and was last updated six years ago
             , rss
             , safe
             , safecopy
             , safeSemaphore
             , sandi
             , sat
             , scientific
             , securemem
             , seereason_keyring
             , seereason_ports
             , semigroups
             , sendfile
             , setenv
             , set_extra
             , sha
             , shake
             , silently
             , smallcheck
             , smtpClient
             , socks
             , split
             , stateVar
             , stb_image
             , strict
             , strict_io
             , stringable
             , stringbuilder
             , stringsearch
             , syb_with_class
             , syb_with_class_instances_text
             , system_fileio
             , system_filepath
             , tagged
             , tagshare
             , tagsoup
             , tar
             , tasty
             , tasty_hunit
             , tasty_quickcheck
             , tasty_smallcheck
             , template_default
             , temporary
             , test_framework
             , test_framework_hunit
             , test_framework_quickcheck
             , test_framework_quickcheck2
             , test_framework_th
             , testing_feat
             , texmath
             , text_icu
             , text_show
             , th_alpha
             , th_context
             , th_desugar
             , th_expand_syns
             -- , th_instance_reification -- deprecated
             , th_lift
             , th_orphans
             , th_reify_many
             , tinymce
             , transformers_base
             , tyb
             , unbounded_delays
             , unicode_names
             , unicode_properties
             , unification_fd
             , union_find
             , uniplate
             , unix_compat
             , unixutils_shadow
             , unordered_containers
             , urlencoded
             , utf8_light
             , utf8_string
             , utility_ht
             , uuid
             , uuid_types
             , vacuum
             , validation
             , vault
             , vc_darcs
             , vc_git_dired
             , vector
             , vector_algorithms
             , virthualenv
             -- , vty -- depends on utf8-string << 0.4
             , wai
             , webdriver
             , web_encodings
             , wl_pprint
             , wl_pprint_extras
             , wl_pprint_text
             , word8
             , word_trie
             , xdg_basedir
             , xml
             -- , xmlhtml
             , xmlgen
             , xml_types
             , xss_sanitize
             , yaml
             , yaml_light
             -- , yi -- depends on failing package hint
             , yi_language
             , yi_rope
             , zip_archive
             ]

compiler :: TSt P.Packages
compiler =
    (baseRelease . release <$> get) >>= \ r ->
    (named "ghc" . map APackage) =<<
    case r of
      Squeeze -> sequence [ ghc76 , po4a, debhelper, dpkg, makedev ]
      _ -> sequence [{-ghc78-}] -- Don't build ghc78 right now, the version we have is fine

platform :: TSt P.Packages
platform =
    named "platform" =<< sequence [{-opengl,-} packages]
    where
      packages =
          (named "platform" . map APackage) =<<
            sequence
            [ happy
            , cabal
            , cabal_install
            , stm
            , stm_chans
            , zlib
            , mtl
            , transformers
            , parallel
            , syb
            , fgl
            , text
            , http_streams
            , http_common
            , openssl_streams
            , alex
            , haskell_src
            , network
            , publicsuffixlist
            , http
            , cgi
            , multipart
            , random
            , hUnit
            , tf_random
            , quickCheck
            , quickCheck1
            , parsec
            , html
            , regex_compat
            , regex_base
            , regex_posix
            ]

clckwrks_group :: TSt P.Packages
clckwrks_group =
    named "clckwrks" =<< sequence [ happstack
                                  , authenticate_group
                                  , happstackdotcom
                                  , packages
                                  , new ]
    where
      packages =
          (Packages . map APackage) <$>
            sequence
            [ clckwrks
            , clckwrks_cli
            , clckwrks_plugin_bugs
            , clckwrks_plugin_media
            , clckwrks_plugin_ircbot
            , clckwrks_theme_bootstrap
            , clckwrks_dot_com
            , clckwrks_theme_clckwrks
            , jmacro
            , monadlist
            , clckwrks_plugin_page ]

fay_group :: TSt P.Packages
fay_group =
    (named "fay" . map APackage) =<<
    sequence
    [ happstack_fay
    , type_eq
    , haskell_names
    , happstack_fay_ajax
    , fay
    , fay_base
    , fay_text
    , fay_jquery
    ]

happstack :: TSt P.Packages
happstack =
    named "happstack" =<< sequence [plugins_group, packages]
    where
      privateRepo = "ssh://upload@src.seereason.com/srv/darcs" :: String
      packages =
          (named "packages" . map APackage) =<<
            sequence
            [ seereason_base
            , happstack_foundation
            , happstack_foundation_example
            , cryptohash_cryptoapi
            , hsx2hs
            , sourcemap
            , haskell_packages
            , hse_cpp
            , happstack_extra
            , traverse_with_class
            , happstack_hsp
            , hsx_jmacro
            , happstack_jmacro
            , jmacro_rpc_happstack
            , jmacro_rpc
            , happstack_search
            , happstack_server
            , happstack_lite
            , happstack_server_tls
            , time_compat
            , base64_bytestring
            , threads
            , list_tries
            , happstack_static_routing
            , happstack_util
            , hsp
            , hslua
            , juicyPixels
            , cmark
            , pandoc
            , markdown
            , highlighting_kate
            , web_routes
            , web_routes_boomerang
            , web_routes_happstack
            , web_routes_hsp
            , web_routes_mtl
            , web_routes_th
            , web_routes_wai
            , happstack_scaffolding
            , hJScript
            , reform
            , reform_blaze
            , reform_hamlet
            , reform_happstack
            , reform_hsp
            , blaze_builder
            , blaze_markup
            , blaze_from_html
            , blaze_html
            , blaze_textual
            , blaze_textual_native
            , happstack_clckwrks
            , happstack_dot_com
            , acid_state
            ]

authenticate_group =
    named "authenticate" =<< sequence [conduit_group, digestive_functors_group, packages]
    where
      packages =
          (named "authpackages" . map APackage) =<<
            sequence
            [ pureMD5
            , monadcryptorandom
            , rsa
            , drbg
            , prettyclass
            , cipher_aes128
            , resourcet
            , mmorph
            , void
            , certificate
            , pem
            , zlib_bindings
            , tls
            , asn1_encoding
            , asn1_parse
            , x509
            , x509_store
            , x509_system
            , x509_validation
            , cipher_rc4
            , crypto_pubkey
            , crypto_numbers
            , crypto_cipher_types
            , authenticate
            , zlib_enum
            , happstack_authenticate_0
            , happstack_authenticate
            , ixset_typed
            , jwt
            , mime_mail
            , aeson_qq
            , fb
            , monad_logger
            , monad_loops
            , fast_logger
            , auto_update
            , date_cache
            , unix_time
            ]

digestive_functors_group =
    (named "digestive-functors" . map APackage) =<<
    sequence
    [ digestive_functors
    , digestive_functors_happstack
    , digestive_functors_hsp
    ]

-- | We need new releases of all the conduit packages before we can move
-- from conduit 0.4.2 to 0.5.
conduit_group =
  (named "conduit" . map APackage) =<<
    sequence
    [ streaming_commons
    , conduit
    , text_stream_decode
    , connection
    , http_conduit
    , http_client
    , http_client_tls
    , xml_conduit
    , tagstream_conduit
    , conduit_extra
    , mime_types
    ]


-- ircbot needs a dependency on containers
happstackdotcom =
    (named "happstackdotcom" . map APackage) =<<
    sequence
    [ ircbot
    , safeSemaphore
    , happstackDotCom_doc ]

shakespeare_group =
    (named "shakespeare-group" . map APackage) =<<
    sequence
    [ wai_extra
    , warp
    , cryptohash_conduit
    , wai_app_static
    , network_conduit
    , simple_sendfile
    , streaming_commons
    , wai_logger
    , http_date
    , shakespeare
    ]

-- May work with these added dependencies (statevar thru openglraw)
opengl :: TSt P.Packages
opengl =
    (named "opengl" . map APackage) =<<
    sequence
    [ openGL
    , bitmap_opengl
    , glut
    , stateVar
    , tensor
    , gluRaw
    , objectName
    , monad_task
    , glfw
    , glfw_task
    , bindings_gLFW
    , bindings_dSL
    , ftgl
    , openGLRaw
    ]

algebra :: TSt P.Packages
algebra =
    (named "algebra" . map APackage) =<<
    sequence [ data_lens
             , data_lens_template
             , bifunctors
             , categories
             , comonad
             , control_monad_free
             , transformers_free
             , contravariant
             , foreign_var
             , distributive
             , doctest
             , transformers_compat
             , profunctors
             , reflection
             , prelude_extras
             , free
             , keys
             , intervals
             , numeric_extras
             , lens
             , constraints
             , lens_family_core
             , lens_family
             , lens_family_th
             , adjunctions
             , linear
             , semigroupoids
             , spine ]

-- CB I was after units, but it requires ghc 7.8
units_group :: TSt P.Packages
units_group =
   (named "units" . map APackage) =<<
   sequence
    [ quickcheck_instances
    , mainland_pretty
    , srcloc
    , singletons
    , th_desugar
    , processing
    , units
    ]

sunroof :: TSt P.Packages
sunroof =
  (named "sunroof" . map APackage) =<<
  sequence
  [ sunroof_compiler
  , constrained_normal
  , set_monad
  , data_reify
  , boolean
  , vector_space
  , numInstances
  , memoTrie
  , value_supply
  , reified_records
  , seclib
  ]

idris_group :: TSt P.Packages
idris_group =
    (named "idris" . map APackage) =<<
        sequence
        [ idris
        , vector_binary_instances
        , trifecta
        , parsers
        , language_java
        , cheapskate
        , annotated_wl_pprint
        , fingertree
        , reducers
        ]

haste :: TSt P.Packages
haste = (named "haste" . map APackage) =<<
  sequence
  [ haste_compiler
  , haste_ffi_parser
  , data_binary_ieee754
  , shellmate
  , websockets
  , io_streams
  ]

-- agda = P.Packages (singleton "agda")
--   [ hack "agda"
--   ]
--     where hack = debianize . hackage
--           git' n r = debianize $ git n r


-- ghcjs TO DO:
--   1. fix cabal-debian so it really knows which packages ghc
--      conflicts with and which it just provides
-- x 2. Merge ghcjs and ghcjs-tools
-- * 3. Don't hard code the version numbers in the wrapper scripts (or haskell-devscripts)
--   4. Make it so we don't have to set $HOME in Setup.hs
-- * 5. Figure out how to require the version of Cabal bundled with ghc (done)
--   6. Build everything into a prefix directory instead of into /usr
--   7. Build cabal-debian with Cabal >= 1.21 - otherwise there's no GHCJS constructor.  Remove ifdefs.  Add note about where to find cabal-ghcjs.
--   8. Enable documentation packages in haskell-devscripts
--   9. Enable -prof packages(?)

ghcjs_group :: TSt P.Packages
ghcjs_group =
    named "ghcjs-group" =<< sequence [deps, comp, libs]
    where
      deps = (baseRelease . release <$> get) >>= \ r ->
             case r of
               Precise -> (named "ghcjs-deps" . map APackage) =<< sequence [c_ares, gyp, libv8]
               _ -> pure P.NoPackage
      comp = (named "ghcjs-comp" . map APackage) =<<
             sequence
             [ shelly
             , text_binary
             , enclosed_exceptions
             , nodejs
             , ghcjs_prim
             , haddock_api
             , haddock_library
             , lifted_async
             , ghcjs_tools
             , ghcjs ]
      libs = (named "ghcjs-libs" . map APackage) =<<
             (sequence $
              (map ghcjs_flags
                  [ adjunctions
                  , ansi_terminal
                  , ansi_wl_pprint
                  , base16_bytestring
                  , base64_bytestring
                  , bifunctors
                  , blaze_builder
                  , blaze_html
                  , blaze_markup
                  , byteable
                  , bytestring_builder
                  , comonad
                  , contravariant
                  , cryptohash
                  , data_default_class
                  , data_default
                  , data_default_instances_base
                  , data_default_instances_containers
                  , data_default_instances_dlist
                  , data_default_instances_old_locale
                  , data_lens
                  , data_lens_template
                  , distributive
                  , exceptions
                  , file_embed
                  , filemanip
                  , foreign_var
                  , free
                  , hslogger
                  , html
                  , http_types
                  , lens
                  , kan_extensions
                  , logict
                  , lucid
                  , monad_control
                  , nats
                  , network
                  , network_uri
                  , optparse_applicative
                  , parsec
                  , prelude_extras
                  , profunctors
                  , random
                  , reflection
                  , regex_base
                  , regex_tdfa_rc
                  , semigroupoids
                  , semigroups
                  , sendfile
                  , smallcheck
                  , split
                  , stateVar
                  , system_filepath
                  , tagged
                  , tasty
                  , tasty_smallcheck
                  , text_show
                  , tf_random
                  , th_lift
                  , threads
                  , time_compat
                  , transformers_base
                  , transformers_compat
                  , unbounded_delays
                  , unix_compat
                  , utf8_string
                  , value_supply
                  , void
                  , (web_routes `flag` P.BuildDep "libghcjs-split-dev") -- the ghcjs version doesn't understand "if impl(ghc >= 7.2) build-depends: split"
                  , web_routes_th
                  , xhtml
                  , zlib
                  ]) ++
              [ ghcjs_dom
              , ghcjs_dom_hello
              , ghcjs_vdom
              , ghcjs_ffiqq
              , ghcjs_jquery ])

darcs_group =
    (named "darcs" . map APackage) =<<
    sequence [haskell_darcs, regex_applicative]

--------------------------------------------------
-- INDIVIDUAL PACKAGES (alphabetized by symbol) --
--------------------------------------------------

abstract_deque :: TSt Package
abstract_deque = debianize (hackage "abstract-deque")
abstract_par = debianize (hackage "abstract-par")
acid_state = debianize (hackage "acid-state" {- `patch` $(embedFile "patches/acid-state.diff") -})
adjunctions = debianize (hackage "adjunctions")
aeson = debianize (hackage "aeson")
aeson_pretty = debianize (hackage "aeson-pretty")
aeson_qq = debianize (hackage "aeson-qq")
agi = darcs ("http://src.seereason.com/haskell-agi")
alex = pure $ P.Package { P.spec = Debianize'' (Hackage "alex") Nothing
                        -- alex shouldn't rebuild just because alex seems newer, but alex does require
                        -- an installed alex binary to build
                        , P.flags = [P.RelaxDep "alex",
                                     P.BuildDep "alex",
                                     P.BuildDep "happy",
                                     P.CabalDebian ["--executable", "alex"],
                                     P.ModifyAtoms (execCabalM $
                                                               do (debInfo . compat) ~= Just 9
                                                                  mapM_ (\ name -> (debInfo . atomSet) %= (Set.insert $ InstallData (BinPkgName "alex") name name))
                                                                       [ "AlexTemplate"
                                                                       , "AlexTemplate-debug"
                                                                       , "AlexTemplate-ghc"
                                                                       , "AlexTemplate-ghc-debug"
                                                                       , "AlexTemplate-ghc-nopred"
                                                                       , "AlexWrapper-basic"
                                                                       , "AlexWrapper-basic-bytestring"
                                                                       , "AlexWrapper-gscan"
                                                                       , "AlexWrapper-monad"
                                                                       , "AlexWrapper-monad-bytestring"
                                                                       , "AlexWrapper-monadUserState"
                                                                       , "AlexWrapper-monadUserState-bytestring"
                                                                       , "AlexWrapper-posn"
                                                                       , "AlexWrapper-posn-bytestring"
                                                                       , "AlexWrapper-strict-bytestring"]) ] }
annotated_wl_pprint = hack "annotated-wl-pprint"
ansi_terminal = debianize (hackage "ansi-terminal")
ansi_wl_pprint = debianize (hackage "ansi-wl-pprint")
appar = debianize (hackage "appar" `flag` P.DebVersion "1.1.4-1")
applicative_extras = debianize (hackage "applicative-extras" `flag` P.DebVersion "0.1.8-1")
archive = debianize (git "https://github.com/seereason/archive" [] `flag` P.CabalDebian ["--default-package=archive"])
asn1_data = debianize (hackage "asn1-data" `tflag` P.DebVersion "0.7.1-4build1")
asn1_encoding = debianize (hackage "asn1-encoding")
asn1_parse = debianize (hackage "asn1-parse")
asn1_types = debianize (hackage "asn1-types")
async = debianize (hackage "async")
             -- Waiting for a newer GHC
             -- , debianize (hackage "units" `flag` P.CabalPin "1.0.0" {- `patch` $(embedFile "patches/units.diff") -})
atomic_primops = debianize (hackage "atomic-primops")
attempt = debianize (hackage "attempt")
attoparsec = debianize (hackage "attoparsec")
attoparsec_enumerator = debianize (hackage "attoparsec-enumerator")
             -- This was merged into attoparsec
             -- , debianize (hackage "attoparsec-text" `patch` $(embedFile "patches/attoparsec-text.diff") `flag` P.Revision "")
             -- Deprecated
             -- , debianize (hackage "attoparsec-text-enumerator")
authenticate = debianize (hackage "authenticate")
autobuilder = debianize (git "https://github.com/ddssff/autobuilder" []) `flag` P.CabalDebian [ "--source-package-name", "autobuilder" ]
autobuilder_seereason =
    debianize (git "https://github.com/ddssff/autobuilder-seereason" [])
                 -- It would be nice if these dependencies were in the cabal file
                 `flag` P.CabalDebian [ "--depends=autobuilder-seereason:libghc-autobuilder-seereason-dev"
                                      , "--depends=autobuilder-seereason:ghc"
                                      , "--depends=autobuilder-seereason:debhelper"
                                      , "--depends=autobuilder-seereason:apt-file"
                                      , "--depends=autobuilder-seereason:apt-utils"
                                      , "--depends=autobuilder-seereason:debootstrap"
                                      , "--depends=autobuilder-seereason:rsync"
                                      , "--depends=autobuilder-seereason:dupload"
                                      , "--depends=autobuilder-seereason:darcs"
                                      , "--depends=autobuilder-seereason:git"
                                      , "--depends=autobuilder-seereason:tla"
                                      , "--depends=autobuilder-seereason:mercurial"
                                      , "--depends=autobuilder-seereason:subversion"
                                      , "--depends=autobuilder-seereason:apt"
                                      , "--depends=autobuilder-seereason:build-essential"
                                      , "--depends=autobuilder-seereason:quilt"
                                      , "--depends=autobuilder-seereason:curl"
                                      , "--depends=autobuilder-seereason:debian-archive-keyring"
                                      , "--depends=autobuilder-seereason:seereason-keyring"
                                      -- Pull in the autobuilder-seereason library so the target's
                                      -- debian/Debianize.hs scripts can run.
                                      -- This is needed if the release vendor is ubuntu.  I need
                                      -- to use a real type for the release value instead of a string,
                                      -- then I can just ask the release who its vendor is.
                                      -- , "--depends=autobuilder-seereason:ubuntu-keyring"
                                      -- These are dependencies used by certain debian/Debianize.hs scripts
                                      , "--recommends=autobuilder-seereason:libghc-text-dev"
                                      , "--recommends=autobuilder-seereason:libghc-seereason-ports-dev" -- used by most (all?) of our web apps
                                      , "--recommends=autobuilder-seereason:libghc-happstack-authenticate-dev" -- used by mimo
                                      , "--recommends=autobuilder-seereason:libghc-happstack-foundation-dev" -- used by mimo
                                      , "--recommends=autobuilder-seereason:libghc-safecopy-dev" -- used by mimo
                                      , "--recommends=autobuilder-seereason:libghc-hsp-dev" -- used by mimo
                                      , "--recommends=autobuilder-seereason:libghc-utility-ht-dev" -- used by mimo
                                      ]
                 `flag` P.CabalDebian [ "--conflicts=autobuilder-seereason:autobuilder"
                                      , "--replaces=autobuilder-seereason:autobuilder" ]
                 `flag` P.CabalDebian [ "--executable", "autobuilder-seereason" ]
                 `flag` P.CabalDebian [ "--executable", "seereason-darcs-backups" ]
                 `flag` P.CabalDebian [ "--source-package-name", "autobuilder-seereason" ]
auto_update = debianize (hackage "auto-update")
base16_bytestring = debianize (hackage "base16-bytestring")
base64_bytestring = debianize (hackage "base64-bytestring" `tflag` P.DebVersion "1.0.0.1-1")
base_unicode_symbols = debianize (hackage "base-unicode-symbols" `tflag` P.DebVersion "0.2.2.4-3")
bifunctors = debianize (hackage "bifunctors")
bimap = debianize (hackage "bimap")
bindings_dSL = debianize (hackage "bindings-DSL")
bindings_gLFW = debianize (hackage "bindings-GLFW"
                             -- `patch` $(embedFile "patches/bindings-GLFW.diff")
                             -- `flag` P.DevelDep "libxrandr2"
                             `flag` P.DevelDep "libx11-dev"
                             `flag` P.DevelDep "libgl1-mesa-dev"
                             `flag` P.DevelDep "libxi-dev"
                             `flag` P.DevelDep "libxxf86vm-dev")
bitmap = debianize (hackage "bitmap")
bitmap_opengl = debianize (hackage "bitmap-opengl"
                   `flag` P.DevelDep "libglu1-mesa-dev")
bits_atomic = debianize (hackage "bits-atomic")
bitset = debianize (hackage "bitset")
blaze_builder = debianize (hackage "blaze-builder")
blaze_from_html = debianize (hackage "blaze-from-html")
blaze_html = debianize (hackage "blaze-html")
blaze_markup = debianize (hackage "blaze-markup")
blaze_textual = debianize (hackage "blaze-textual")
blaze_textual_native = debianize (hackage "blaze-textual-native"
                           `patch` $(embedFile "patches/blaze-textual-native.diff")
                           `flag` P.Revision "")
boolean = debianize (hackage "Boolean")
boomerang = debianize (hackage "boomerang")
bugzilla = broken $ apt "squeeze" "bugzilla" -- requires python-central (>= 0.5)
byteable = debianize (hackage "byteable" `tflag` P.DebVersion "0.1.1-1")
byteorder = debianize (hackage "byteorder" `tflag` P.DebVersion "1.0.4-1")
bytes = debianize (hackage "bytes")
bytestring_builder = debianize (hackage "bytestring-builder")
bytestring_nums = debianize (hackage "bytestring-nums") -- apt (rel release "wheezy" "quantal") "haskell-bytestring-nums"
bytestring_trie = debianize (hackage "bytestring-trie")
bzlib = debianize (hackage "bzlib" `flag` P.DevelDep "libbz2-dev")
             -- , debianize (hackage "cairo-pdf")
cabal_debian = git "https://github.com/ddssff/cabal-debian" []
cabal = debianize (hackage "Cabal" `flag` P.CabalPin "1.22.2.0" {- avoid rebuild -}) -- the settings in Debian.AutoBuilder.Details.Versions will name this cabal-122
cabal_install = debianize (hackage "cabal-install" `flag` P.CabalDebian ["--default-package=cabal-install"])
cabal_macosx = debianize (hackage "cabal-macosx" `patch` $(embedFile "patches/cabal-macosx.diff"))
c_ares = apt "sid" "c-ares"
case_insensitive = debianize (hackage "case-insensitive")
             -- Here is an example of creating a debian/Debianize.hs file with an
             -- autobuilder patch.  The autobuilder then automatically runs this
             -- script to create the debianization.
categories = broken $ debianize (hackage "categories" `tflag` P.DebVersion "1.0.6-1")
    -- comonad now includes comonad-transformers and comonads-fd
cautious_file = debianize (hackage "cautious-file" `tflag` P.DebVersion "1.0.2-2")
cc_delcont = debianize (hackage "CC-delcont" `flag` P.DebVersion "0.2-1~hackage1")
             -- , apt (rel release "wheezy" "quantal") "haskell-cereal"
cereal = debianize (hackage "cereal")
certificate = debianize (hackage "certificate" `tflag` P.DebVersion "1.3.9-1build4")
cgi = skip (Reason "Depends on exceptions < 0.7") $ debianize (hackage "cgi" {- `patch` $(embedFile "patches/cgi.diff") -})
charset = debianize (hackage "charset")
charsetdetect_ae = debianize (hackage "charsetdetect-ae")
cheapskate = debianize (git "https://github.com/seereason/cheapskate" [] {-hackage "cheapskate"-})
cipher_aes128 = debianize (hackage "cipher-aes128")
cipher_aes = debianize (hackage "cipher-aes")
cipher_des = debianize (hackage "cipher-des" `tflag` P.DebVersion "0.0.6-1")
cipher_rc4 = debianize (hackage "cipher-rc4" `tflag` P.DebVersion "0.1.4-1")
citeproc_hs = debianize (hackage "citeproc-hs")
clckwrks_cli = debianize (gitrepo "clckwrks-cli")
clckwrks_dot_com = debianize (gitrepo "clckwrks-dot-com"
                               -- This is a change that only relates to the autobuilder
                               `patch` $(embedFile "patches/clckwrks-dot-com.diff"))
clckwrks_plugin_bugs = debianize (gitrepo "clckwrks-plugin-bugs"
                           `flag` P.BuildDep "hsx2hs")
clckwrks_plugin_ircbot = debianize (gitrepo "clckwrks-plugin-ircbot"
                           `flag` P.BuildDep "hsx2hs")
clckwrks_plugin_media = debianize (gitrepo "clckwrks-plugin-media"
                           `flag` P.BuildDep "hsx2hs")
clckwrks_plugin_page = debianize (gitrepo "clckwrks-plugin-page"
                           -- `patch` $(embedFile "patches/clckwrks-plugin-page.diff")
                           `flag` P.BuildDep "hsx2hs")
clckwrks = pure (P.Package { P.spec = Debianize'' (Patch
                                              (DataFiles
                                               (DataFiles
                                                (Git "https://github.com/clckwrks/clckwrks" [])
                                                (Uri "https://cloud.github.com/downloads/vakata/jstree/jstree_pre1.0_fix_1.zip"
                                                     "e211065e573ea0239d6449882c9d860d")
                                                "jstree")
                                               (Uri "https://raw.githubusercontent.com/douglascrockford/JSON-js/master/json2.js"
                                                    "5eecb009ae16dc54f261f31da01dbbac")
                                               "json2")
                                              $(embedFile "patches/clckwrks.diff")) Nothing
                        , P.flags = [P.BuildDep "hsx2hs"] })
clckwrks_theme_bootstrap = debianize (gitrepo "clckwrks-theme-bootstrap" `flag` P.BuildDep "hsx2hs")
clckwrks_theme_clckwrks = debianize (gitrepo "clckwrks-theme-clckwrks" `flag` P.BuildDep "hsx2hs")
clock = debianize (hackage "clock")
closure_compiler = apt "sid" "closure-compiler"
cmark = debianize (hackage "cmark")
cmdargs = debianize (hackage "cmdargs")
colour = debianize (hackage "colour"
                            `pflag` P.DebVersion "2.3.3-1build1"
                            `qflag` P.DebVersion "2.3.3-1build1"
                            `sflag` P.DebVersion "2.3.3-1"
                            `tflag` P.DebVersion "2.3.3-4")
             -- , apt "wheezy" "haskell-configfile"
comonad = debianize (hackage "comonad"
                   `flag`  P.ModifyAtoms (replacement "comonad" "comonad-transformers")
                   `flag`  P.ModifyAtoms (replacement "comonad" "comonad-fd"))
concatenative = debianize (hackage "concatenative")
concrete_typerep = debianize (hackage "concrete-typerep"
                            `tflag` P.DebVersion "0.1.0.2-2build3")
cond = debianize (hackage "cond")
conduit = debianize (hackage "conduit")
conduit_extra = debianize (hackage "conduit-extra")
configFile = debianize (hackage "ConfigFile")
connection = debianize (hackage "connection")
constrained_normal = debianize (hackage "constrained-normal")
constraints = debianize (hackage "constraints")
consumer = darcs ("http://src.seereason.com/haskell-consumer")
contravariant = debianize (hackage "contravariant")
control_monad_free = debianize (hackage "control-monad-free")
cookie = debianize (hackage "cookie")
cpphs = debianize (hackage "cpphs") -- apt (rel release "wheezy" "quantal") "cpphs"
             -- No longer available
             -- , apt "sid" "debian-keyring=2014.03.03" -- The current version (2014.04.25) seems to be missing some keys that we need
cprng_aes = debianize (hackage "cprng-aes")
cpu = debianize (hackage "cpu" `tflag` P.DebVersion "0.1.2-1")
crypto_api = debianize (hackage "crypto-api" `qflag` P.DebVersion "0.10.2-1build3")
             -- The certificate package may need to be updated for version 0.4
crypto_cipher_types = debianize (hackage "crypto-cipher-types" `tflag` P.DebVersion "0.0.9-1")
crypto = debianize (hackage "Crypto")
cryptohash_conduit = debianize (hackage "cryptohash-conduit")
cryptohash_cryptoapi = debianize (hackage "cryptohash-cryptoapi")
cryptohash = debianize (hackage "cryptohash")
crypto_numbers = debianize (hackage "crypto-numbers")
crypto_pubkey = debianize (hackage "crypto-pubkey")
crypto_pubkey_types = debianize (hackage "crypto-pubkey-types")
             -- crypto-pubkey-types-0.3.2 depends on older asn1-types
crypto_random_api = debianize (hackage "crypto-random-api" `tflag` P.DebVersion "0.2.0-2")
crypto_random = debianize (hackage "crypto-random")
css = debianize (hackage "css")
css_text = debianize (hackage "css-text")
csv = debianize (hackage "csv"
                            `pflag` P.DebVersion "0.1.2-2"
                            `tflag` P.DebVersion "0.1.2-5build1")
curl = debianize (hackage "curl" `tflag` P.DebVersion "1.3.8-2") -- apt (rel release "wheezy" "quantal") "haskell-curl"
currency = debianize (hackage "currency")
data_accessor = debianize (hackage "data-accessor")
data_accessor_template = debianize (hackage "data-accessor-template")
data_binary_ieee754 = hack "data-binary-ieee754"
data_default_class = debianize (hackage "data-default-class" `tflag` P.DebVersion "0.0.1-1")
data_default = debianize (hackage "data-default")
data_default_instances_base = debianize (hackage "data-default-instances-base")
data_default_instances_containers = debianize (hackage "data-default-instances-containers")
data_default_instances_dlist = debianize (hackage "data-default-instances-dlist")
data_default_instances_old_locale = debianize (hackage "data-default-instances-old-locale")
dataenc = debianize (hackage "dataenc" {- `patch` $(embedFile "patches/dataenc.diff") -})
data_lens = debianize (hackage "data-lens" `patch` $(embedFile "patches/data-lens.diff"))
data_lens_template = debianize (hackage "data-lens-template")
data_object = debianize (hackage "data-object" `patch` $(embedFile "patches/data-object.diff"))
data_ordlist = debianize (hackage "data-ordlist")
data_reify = debianize (hackage "data-reify")
data_r_tree = debianize (hackage "data-r-tree")
data_stringmap = debianize (hackage "data-stringmap")
date_cache = debianize (hackage "date-cache" `tflag` P.DebVersion "0.3.0-3")
datetime = debianize (hackage "datetime" `pflag` P.DebVersion "0.2.1-2" `tflag` P.DebVersion "0.2.1-5build1")
debhelper = apt "wheezy" "debhelper" `patch` $(embedFile "patches/debhelper.diff")
debian_haskell = git "https://github.com/ddssff/debian-haskell" [] `flag` P.RelaxDep "cabal-debian"
debian_repo = git "https://github.com/ddssff/debian-repo" []
debootstrap = apt "sid" "debootstrap" `flag` P.UDeb "debootstrap-udeb"
             -- Build fails due to some debianization issue
             -- , apt "wheezy" "geneweb"
decimal = debianize (hackage "Decimal") -- for hledger
deepseq_generics = debianize (hackage "deepseq-generics")
derive = debianize (hackage "derive")
diff = debianize (hackage "Diff")
digest = debianize (hackage "digest")
digestive_functors = debianize (hackage "digestive-functors" `flag` P.CabalPin "0.2.1.0")  -- Waiting to move all these packages to 0.3.0.0 when hsp support is ready
    -- , debianize "digestive-functors-blaze" [P.CabalPin "0.2.1.0", P.DebVersion "0.2.1.0-1~hackage1"]
digestive_functors_happstack = debianize (git "https://github.com/seereason/digestive-functors" []
                   `cd` "digestive-functors-happstack"
                   `flag` P.DebVersion "0.1.1.5-2")
digestive_functors_hsp = debianize (darcs ("http://src.seereason.com/digestive-functors-hsp") `flag` P.BuildDep "hsx2hs")
directory_tree = debianize (hackage "directory-tree")
distributive = debianize (hackage "distributive")
dlist = debianize (hackage "dlist")
             -- Natty only(?)
doctest = debianize (hackage "doctest")
    -- This package fails to build in several different ways because it has no modules.
    -- I am just going to patch the packages that use it to require transformers >= 0.3.
    -- Specifically, distributive and lens.
double_conversion = debianize (hackage "double-conversion")
dpkg = apt "wheezy" "dpkg" `patch` $(embedFile "patches/dpkg.diff")
drbg = debianize (hackage "DRBG")
dynamic_state = debianize (hackage "dynamic-state")
dyre = debianize (hackage "dyre")
easy_file = debianize (hackage "easy-file")
edisonAPI = (release <$> get) >>= \ r ->
               pure (P.Package { P.spec = Debianize'' (Hackage "EdisonAPI") Nothing
                               , P.flags = rel r [] [P.DebVersion "1.2.1-18build2"] })
edisonCore = (debianize (hackage "EdisonCore" `qflag` P.DebVersion "1.2.1.3-9build2"))
ekg_core = debianize (hackage "ekg-core")
enclosed_exceptions = debianize (hackage "enclosed-exceptions")
entropy = debianize (hackage "entropy")
enumerator = debianize (hackage "enumerator" `qflag` P.DebVersion "0.4.19-1build2")
erf = debianize (hackage "erf"
                            `pflag` P.DebVersion "2.0.0.0-3"
                            `wflag` P.DebVersion "2.0.0.0-3"
                            `tflag` P.DebVersion "2.0.0.0-5")
errors = debianize (hackage "errors")
exceptions = debianize (hackage "exceptions")
executable_path = debianize (hackage "executable-path"
                            `pflag` P.DebVersion "0.0.3-1"
                            `tflag` P.DebVersion "0.0.3-3")
             -- , apt (rel release "wheezy" "quantal") "haskell-digest"
             -- , apt (rel release "wheezy" "quantal") "haskell-dlist"
extensible_exceptions = debianize (hackage "extensible-exceptions" -- required for ghc-7.6.  Conflicts with ghc-7.4 in wheezy.
                            `tflag` P.DebVersion "0.1.1.4-2")
extra = debianize (hackage "extra")
failure = debianize (hackage "failure")
fast_logger = debianize (hackage "fast-logger")
fay_base = debianize (hackage "fay-base")
fay = debianize (hackage "fay" {- `patch` $(embedFile "patches/fay.diff") -}) `flag` P.CabalDebian [ "--depends=haskell-fay-utils:cpphs" ]
fay_jquery = debianize (git "https://github.com/faylang/fay-jquery" [])
    -- , debianize (hackage "fay-jquery" `flag` P.CabalPin "0.3.0.0")
fay_text = debianize (hackage "fay-text")
fb = debianize (git "https://github.com/ddssff/fb.git" [])
feed = debianize (git "https://github.com/seereason/feed" [] {-hackage "feed"-} `tflag` P.DebVersion "0.3.9.2-1")
fgl = debianize (hackage "fgl")
file_embed = debianize (hackage "file-embed")
file_location = debianize (hackage "file-location" `flag` P.CabalDebian [ "--source-package-name", "file-location" ])
filemanip = debianize (hackage "filemanip")
filemanip_extra = debianize (git "https://github.com/seereason/filemanip-extra" [])
fingertree = hack "fingertree"
fmlist = debianize (hackage "fmlist")
foreign_var = debianize (hackage "foreign-var")
formlets = debianize (hackage "formlets"
                             `patch` $(embedFile "patches/formlets.diff")
                             `flag` P.DebVersion "0.8-1~hackage1")
free = debianize (hackage "free")
frquotes = debianize (hackage "frquotes")
             -- Usable versions of this package are available in some dists -
             -- e.g. trusty and wheezy.
             -- , apt "trusty" "foo2zjs"
fsnotify = debianize (hackage "fsnotify")
ftgl = debianize (hackage "FTGL"
                   -- `patch` $(embedFile "patches/FTGL.diff")
                   `flag` P.DevelDep "libftgl-dev"
                   `flag` P.DevelDep "libfreetype6-dev")
gd = debianize (hackage "gd"
                             `patch` $(embedFile "patches/gd.diff")
                             `flag` P.DevelDep "libgd-dev"
                             `flag` P.DevelDep "libc6-dev"
                             `flag` P.DevelDep "libfreetype6-dev"
                             `wflag` P.DebVersion "3000.7.3-1"
                             `qflag` P.DebVersion "3000.7.3-1build2"
                             `tflag` P.DebVersion "3000.7.3-3")
             -- , debianize (flags [P.BuildDep "libm-dev", P.BuildDep "libfreetype-dev"] (hackage "gd"))
gdiff = debianize (hackage "gdiff")
             -- , debianize (hackage "hjsmin")
generic_deriving = debianize (hackage "generic-deriving")
genI = debianize (darcs "http://hub.darcs.net/kowey/GenI" `patch` $(embedFile "patches/GenI.diff"))
ghc76 = ghcFlags $ apt "sid" "ghc" `patch` $(embedFile "patches/ghc.diff")
ghc78 = ghcFlags $ apt "experimental" "ghc" `patch` $(embedFile "patches/trac9262.diff")
ghcjs_jquery = ghcjs_flags (debianize (git "https://github.com/ghcjs/ghcjs-jquery" []) `putSrcPkgName` "ghcjs-ghcjs-jquery")
ghcjs_vdom = ghcjs_flags (debianize (git "https://github.com/seereason/ghcjs-vdom" []) `putSrcPkgName` "ghcjs-ghcjs-vdom")
ghcjs_ffiqq = ghcjs_flags (debianize (git "https://github.com/ghcjs/ghcjs-ffiqq" []) `putSrcPkgName` "ghcjs-ghcjs-ffiqq")
ghcjs_dom = ghcjs_flags (debianize (hackage "ghcjs-dom"))
ghcjs_dom_hello = ghcjs_flags (debianize (hackage "ghcjs-dom-hello"
                                                      `patch` $(embedFile "patches/ghcjs-dom-hello.diff")
                                                       `flag` P.CabalDebian ["--default-package=ghcjs-dom-hello"]))
ghcjs = git "https://github.com/ddssff/ghcjs-debian" [] `relax` "cabal-install"
ghcjs_prim = debianize (git "https://github.com/ghcjs/ghcjs-prim.git" [])
ghcjs_tools = git "https://github.com/ghcjs/ghcjs" []
                 `patch` $(embedFile "patches/ghcjs-0002-Force-HOME-to-be-usr-lib-ghcjs-during-build.patch")
                 `patch` $(embedFile "patches/ghcjs-0003-Allow-builds-even-if-repository-has-uncommitted-chan.patch")
                 `patch` $(embedFile "patches/ghcjs-0004-Add-debianization.patch")
                 `patch` $(embedFile "patches/ghcjs-0005-Use-the-value-of-BRANCH-inherited-from-the-parent-pr.patch")
                 `patch` $(embedFile "patches/ghcjs-0006-Force-the-use-of-branch-master-of-the-shims-repo.patch")
                 `patch` $(embedFile "patches/ghcjs-0007-Use-ghc-in-prepare_setup_scripts-if-ghcjs-not-availa.patch")
                 `patch` $(embedFile "patches/ghcjs-0008-Restrict-the-transformers-package-to-the-exact-versi.patch")
                 `patch` $(embedFile "patches/ghcjs-0009-Add-a-MonadTrans-instance-for-ReaderT-and-a-liftRead.patch")
                 `patch` $(embedFile "patches/ghcjs-0010-alternate-ghcjs-boot-repo.patch")
                 `relax` "cabal-install"
                 `flag` P.KeepRCS
ghc_mtl = skip (Reason "No instance for (MonadIO GHC.Ghc)") $ debianize (hackage "ghc-mtl")
ghc_paths = debianize (hackage "ghc-paths" `tflag` P.DebVersion "0.1.0.9-3") -- apt (rel release "wheezy" "quantal") "haskell-ghc-paths" -- for leksah
             -- Unpacking haskell-gtk2hs-buildtools-utils (from .../haskell-gtk2hs-buildtools-utils_0.12.1-0+seereason1~lucid2_amd64.deb) ...
             -- dpkg: error processing /work/localpool/haskell-gtk2hs-buildtools-utils_0.12.1-0+seereason1~lucid2_amd64.deb (--unpack):
             --  trying to overwrite '/usr/bin/gtk2hsTypeGen', which is also in package gtk2hs-buildtools 0:0.12.0-3+seereason1~lucid3
             -- dpkg-deb: subprocess paste killed by signal (Broken pipe)
             -- Errors were encountered while processing:
             --  /work/localpool/haskell-gtk2hs-buildtools-utils_0.12.1-0+seereason1~lucid2_amd64.deb
             -- E: Sub-process /usr/bin/dpkg returned an error code (1)
glfw = debianize (hackage "GLFW" `flag` P.DevelDep "libglu1-mesa-dev")
    -- , debianize (hackage "GLFW-b")
    -- , debianize (hackage "GLFW-b-demo" `flag` P.SkipPackage {- `patch` $(embedFile "patches/GLFW-b-demo.diff") -})
glfw_task = debianize (hackage "GLFW-task")
gluRaw = debianize (hackage "GLURaw")
glut = debianize (hackage "GLUT"
                   `flag` P.DevelDep "freeglut3-dev")
groom = debianize (hackage "groom")
             -- Retired
             -- , apt "wheezy" "haskell-dummy"
             -- Need this when we upgrade blaze-textual to 0.2.0.0
             -- , lucidNatty (hackage release "double-conversion" []) (debianize "double-conversion" [])
gtk2hs_buildtools = debianize (hackage "gtk2hs-buildtools"
                            `flag` P.CabalDebian ["--build-dep", "alex",
                                                  "--build-dep", "happy",
                                                  "--revision", ""])
             -- , debianize "AES" [P.DebVersion "0.2.8-1~hackage1"]
gyp = apt "sid" "gyp"
haddock_api = debianize (hackage "haddock-api"
                            `flag` P.CabalPin "2.15.0.2" -- 2.16 requires ghc-7.10
                            `flag` P.CabalDebian ["--default-package=haddock-api"]
                            -- FIXME - This cabal-debian stuff does nothing because this isn't a Debianize target
                            `flag` P.ModifyAtoms (execCabalM $ (debInfo . rulesFragments) += Text.unlines
                                                               [ "# Force the Cabal dependency to be the version provided by GHC"
                                                               , "DEB_SETUP_GHC_CONFIGURE_ARGS = --constraint=Cabal==$(shell dpkg -L ghc | grep 'package.conf.d/Cabal-' | sed 's/^.*Cabal-\\([^-]*\\)-.*$$/\\1/')\n"]))
haddock_library = debianize (hackage "haddock-library"`flag` P.CabalPin "1.1.1") -- 1.2.0 is too new for haddock-api-2.15.0.2
hamlet = debianize (hackage "hamlet")
happstack_authenticate_0 = debianize (git "https://github.com/Happstack/happstack-authenticate-0.git" []
                           `flag` P.CabalDebian [ "--debian-name-base", "happstack-authenticate-0",
                                                  "--cabal-flags", "migrate",
                                                  "--executable", "happstack-authenticate-migrate" ])
happstack_authenticate = debianize (git "https://github.com/Happstack/happstack-authenticate.git" []) -- Use authenticate-0 for now
happstack_clckwrks = debianize (git ("https://github.com/Happstack/happstack-clckwrks") []
                           `cd` "clckwrks-theme-happstack"
                           -- `patch` $(embedFile "patches/clckwrks-theme-happstack.diff")
                           `flag` P.BuildDep "hsx2hs")
happstack_dot_com = debianize (git ("https://github.com/Happstack/happstack-clckwrks") []
                                 `cd` "happstack-dot-com"
                                 -- This is a change that only relates to the autobuilder
                                 `patch` $(embedFile "patches/happstack-dot-com.diff"))
happstackDotCom_doc = darcs ("http://src.seereason.com/happstackDotCom-doc")
happstack_extra = debianize (darcs ("http://src.seereason.com/happstack-extra"))
happstack_fay_ajax = debianize (hackage "happstack-fay-ajax" `patch` $(embedFile "patches/happstack-fay-ajax.diff"))
    -- , debianize (hackage "fay-hsx" `patch` $(embedFile "patches/fay-hsx.diff"))
happstack_fay = debianize (hackage "happstack-fay" `patch` $(embedFile "patches/happstack-fay.diff"))
happstack_foundation = debianize (git "https://github.com/Happstack/happstack-foundation.git" [])
happstack_foundation_example =
    debianize (git "https://github.com/Happstack/happstack-foundation.git" []
                                 `cd` "examples/ControlVAuth"
                                 `flag` P.CabalDebian ["--source-package-name=happstack-foundation-example",
                                                       "--default-package=happstack-foundation-example"])
happstack_hsp = debianize (git "https://github.com/Happstack/happstack-hsp.git" []) -- , debianize (hackage "happstack-hsp" {- `patch` $(embedFile "patches/happstack-hsp.diff") -} `flag` P.BuildDep "hsx2hs")
happstack_jmacro = debianize (git "https://github.com/Happstack/happstack-jmacro.git" [])            -- , debianize (hackage "happstack-jmacro")
happstack_lite = debianize (hackage "happstack-lite")
happstack_plugins = debianize (hackage "happstack-plugins" `patch` $(embedFile "patches/happstack-plugins.diff"))
happstack_scaffolding = debianize (git "https://github.com/seereason/happstack-scaffolding" [] `flag` P.BuildDep "hsx2hs")
happstack_search = darcs ("http://src.seereason.com/happstack-search")
            -- , debianize (hackage "happstack-server")
happstack_server = debianize (git "https://github.com/Happstack/happstack-server" [])
happstack_server_tls = debianize (git "https://github.com/Happstack/happstack-server-tls" [])
happstack_static_routing = debianize (hackage "happstack-static-routing")
happstack_util = debianize (hackage "happstack-util"
                           `patch` $(embedFile "patches/happstack-util.diff")
                           `flag` P.DebVersion "6.0.3-1")
            -- This target puts the trhsx binary in its own package, while the
            -- sid version puts it in libghc-hsx-dev.  This makes it inconvenient to
            -- use debianize for natty and apt:sid for lucid.
happy = broken $ pure $ P.Package { P.spec = DebDir (Hackage "happy") (Darcs ("http://src.seereason.com/happy-debian")),
                                    P.flags = [P.RelaxDep "happy", P.CabalDebian ["--executable", "happy"],
                                               P.Maintainer "SeeReason Autobuilder <partners@seereason.com>"] }
harp = debianize (hackage "harp"
                            `pflag` P.DebVersion "0.4-3"
                            `tflag` P.DebVersion "0.4-6") -- apt (rel release "wheezy" "quantal") "haskell-harp"
hashable = debianize (hackage "hashable")
hashed_storage = debianize (hackage "hashed-storage")
             -- Built into ghc-7.8.3
hashtables = debianize (hackage "hashtables")
haskeline = debianize (hackage "haskeline")
haskell_darcs = debianize (darcs "http://darcs.net/reviewed"
                   `flag` P.CabalDebian ["--source-package-name=darcs"]
                   `flag` P.CabalDebian ["--default-package=darcs"]
                   `flag` P.CabalDebian ["--cabal-flags", "-http"] -- the http flag forces network < 2.5
                   -- `patch` $(embedFile "patches/darcs.diff")
                  )
haskell_devscripts = git "https://github.com/seereason/haskell-devscripts" [] `flag` P.RelaxDep "python-minimal"
haskell_either = debianize (hackage "either")
haskell_extra = debianize (git ("https://github.com/seereason/sr-extra") []
                            -- Don't push out libghc-extra-dev, it now comes from Neil Mitchell's repo
                            {- `flag` P.ModifyAtoms (replacement "sr-extra" "Extra") -})
haskell_help = debianize (git ("https://github.com/seereason/sr-help") [])
haskell_lexer = debianize (hackage "haskell-lexer"
                            `pflag` P.DebVersion "1.0-3build2"
                            `wflag` P.DebVersion "1.0-3+b1"
                            `tflag` P.DebVersion "1.0-5")
haskell_list = debianize (hackage "List")
haskell_names = debianize (hackage "haskell-names")
haskell_newtype = debianize (hackage "newtype" `wflag` P.DebVersion "0.2-1" `tflag` P.DebVersion "0.2-3")
haskell_packages = debianize (hackage "haskell-packages" `patch` $(embedFile "patches/haskell-packages.diff"))
haskell_revision = debianize (git ("https://github.com/seereason/sr-revision") [])
haskell_src = debianize (hackage "haskell-src" `flag` P.BuildDep "happy")
haskell_src_exts = debianize (-- darcs "haskell-haskell-src-exts" "http://code.haskell.org/haskell-src-exts"
                          hackage "haskell-src-exts"
                            `flag` P.BuildDep "happy")
haskell_src_meta = debianize (git "https://github.com/ddssff/haskell-src-meta" [] {- hackage "haskell-src-meta" -})
             -- Because we specify an exact debian version here, this package
             -- needs to be forced to rebuilt when its build dependencies (such
             -- as ghc) change.  Autobuilder bug I suppose.  Wait, this doesn't
             -- sound right...
haste_compiler = hack "haste-compiler" `flag` P.CabalDebian ["--default-package=haste-compiler"]
haste_ffi_parser = git' "https://github.com/RudolfVonKrugstein/haste-ffi-parser" []
haTeX = debianize (git "https://github.com/Daniel-Diaz/HaTeX" [Commit "cc66573a0587094667a9150411ea748d6592db36" {-avoid rebuild-}]
                              `patch` $(embedFile "patches/HaTeX-texty.diff")
                              `patch` $(embedFile "patches/HaTeX-doc.diff"))
haXml = debianize (hackage "HaXml")
hdaemonize = debianize (git "https://github.com/madhadron/hdaemonize" [])
heap = debianize (hackage "heap")
             -- , debianize (hackage "heist" `patch` $(embedFile "patches/heist.diff"))
hexpat = debianize (git "https://github.com/ddssff/hexpat.git" []) -- debianize (hackage "hexpat")
highlighting_kate = debianize (hackage "highlighting-kate")
hinotify = debianize (hackage "hinotify")
hint = debianize (hackage "hint")
hJavaScript = debianize (hackage "HJavaScript"
                            `patch` $(embedFile "patches/hjavascript.diff")
                            `pflag` P.DebVersion "0.4.7-3++1"
                            `tflag` P.DebVersion "0.4.7-6")
             -- Not used, and not building.
             -- , debianize (hackage "hoauth")
hJScript = debianize (hackage "HJScript")
hledger = debianize (git "https://github.com/simonmichael/hledger" [] `cd` "hledger-lib")
         {-
             -- Needs a build dependency on libXrandr-dev and the cabal package x11.
             , P.Package { P.spec = Debianize (Hackage "xmobar")
                         , P.flags = [] }
         -}
             -- Needs update for current http-conduit
             -- , debianize $ (hackage "dropbox-sdk") `patch` $(embedFile "patches/dropbox-sdk.diff")
hostname = debianize (hackage "hostname"
                            `wflag` P.DebVersion "1.0-4"
                            `pflag` P.DebVersion "1.0-4build1"
                            `qflag` P.DebVersion "1.0-4build3"
                            `sflag` P.DebVersion "1.0-1~hackage1"
                            `tflag` P.DebVersion "1.0-6")
             -- The Sid package has no profiling libraries, so dependent packages
             -- won't build.  Use our debianization instead.  This means keeping
             -- up with sid's version.
hourglass = debianize (hackage "hourglass")
hpdf = debianize (hackage "HPDF")
hS3 = debianize (git "https://github.com/scsibug/hS3.git" [])
                             `flag` P.ModifyAtoms (execCabalM $ doExecutable (BinPkgName "hs3") (InstallFile {execName = "hs3", sourceDir = Nothing, destDir = Nothing, destName = "hs3"}))
hs_bibutils = debianize (hackage "hs-bibutils")
hscolour = debianize (hackage "hscolour") `flag` P.RelaxDep "hscolour"
hse_cpp = debianize (hackage "hse-cpp")
hsemail = debianize (hackage "hsemail") -- (rel release [] [P.DebVersion "1.7.1-2build2"])
hslogger = debianize (hackage "hslogger")
hslua = debianize (hackage "hslua")
hsOpenSSL = debianize (hackage "HsOpenSSL"
                            `flag` P.DevelDep "libssl-dev"
                            `flag` P.DevelDep "libcrypto++-dev")
hsp = debianize (hackage "hsp" `flag` P.BuildDep "hsx2hs")
hspec = debianize (hackage "hspec")
hspec_core = debianize (hackage "hspec-core")
hspec_discover = debianize (hackage "hspec-discover")
hspec_expectations = debianize (hackage "hspec-expectations")
hspec_meta = debianize (hackage "hspec-meta")
hsSyck = debianize (hackage "HsSyck")
hStringTemplate = skip (Reason "Needs time-1.5") (debianize (hackage "HStringTemplate"))
hsx2hs = debianize (git "https://github.com/seereason/hsx2hs.git" []
                         -- hackage "hsx2hs" `patch` $(embedFile "patches/hsx2hs.diff")
                           `flag` P.CabalDebian ["--executable", "hsx2hs",
                                                 "--conflicts=hsx2hs:haskell-hsx-utils",
                                                 "--replaces=hsx2hs:haskell-hsx-utils",
                                                 "--provides=hsx2hs:haskell-hsx-utils"])
            -- maybe obsolete, src/HTML.hs:60:16: Not in scope: `selectElement'
hsx_jmacro = debianize (git "https://github.com/Happstack/hsx-jmacro.git" [])
hsyslog = debianize (hackage "hsyslog")
htf = debianize (hackage "HTF" `flag` P.BuildDep "cpphs")
html = debianize (hackage "html"
                           `tflag` P.DebVersion "1.0.1.2-7"
                           `pflag` P.DebVersion "1.0.1.2-5") -- apt (rel release "wheezy" "quantal") "haskell-html"
html_entities = darcs ("http://src.seereason.com/html-entities")
html_xml_utils = (baseRelease . release <$> get) >>= \ r ->
               case r of
                 Quantal -> zero -- This build hangs when performing tests
                 Wheezy -> zero -- This build hangs when performing tests
                 _ -> apt "sid" "html-xml-utils"
http_client = debianize (hackage "http-client")
http_client_tls = debianize (hackage "http-client-tls")
    -- Deprecated in favor of http-conduit
    -- , debianize (hackage "http-client-conduit" {- `flag` P.CabalPin "0.2.0.1" -})
    -- Deprecated in favor of conduit-extra
    -- , debianize (hackage "attoparsec-conduit" {- `flag` P.CabalPin "1.0.1.2" `tflag` P.DebVersion "1.0.1.2-1build2" -})
    -- , debianize (hackage "blaze-builder-conduit" {- `flag` P.CabalPin "1.0.0" `tflag` P.DebVersion "1.0.0-2build4" -})
    -- , debianize (hackage "zlib-conduit" {- `flag` P.CabalPin "1.0.0" `tflag` P.DebVersion "1.0.0-2build3" -})
http_common = debianize (hackage "http-common")
http_conduit = debianize (hackage "http-conduit")
http_date = debianize (hackage "http-date")
http = debianize (hackage "HTTP")
http_streams = debianize (hackage "http-streams" {- `patch` $(embedFile "patches/http-streams.diff") -})
http_types = debianize (hackage "http-types" {- `patch` $(embedFile "patches/http-types.diff") -})
hUnit = debianize (hackage "HUnit" `tflag` P.DebVersion "1.2.5.2-1")
hunt = debianize (git "https://github.com/hunt-framework/hunt.git" [] `cd` "hunt-searchengine" )
hxt_charproperties = debianize (hackage "hxt-charproperties")
hxt = debianize (hackage "hxt" `flag` P.CabalDebian ["--cabal-flags", "network-uri"])
hxt_regex_xmlschema = debianize (hackage "hxt-regex-xmlschema")
hxt_unicode = debianize (hackage "hxt-unicode")
             -- , debianize (darcs "haskell-tiny-server" ("http://src.seereason.com/tiny-server") `flag` P.BuildDep "hsx2hs"
             --                `flag` P.SkipPackage {- has a "derives SafeCopy" -})
i18n = debianize (hackage "i18n" `flag` P.DebVersion "0.3-1~hackage1")
iconv = debianize (hackage "iconv")
idris = debianize (hackage "idris"
                       -- `patch` $(embedFile "patches/idris.diff") -- adds *.idr to extra-source-files
                       `flag` P.BuildDep "libgc-dev"
                       `flag` P.CabalDebian ["--default-package=idris"])
incremental_sat_solver = pure $ P.Package { P.spec = DebDir (Hackage "incremental-sat-solver") (Darcs ("http://src.seereason.com/haskell-incremental-sat-solver-debian"))
                                , P.flags = [] }
indents = debianize (hackage "indents")
instant_generics = broken $ debianize (hackage "instant-generics" `flag` P.SkipVersion "0.3.7")
intervals = debianize (hackage "intervals")
ioRefCAS = skip (Reason "Version 0.2.0.1 build fails") $ debianize (hackage "IORefCAS")
io_storage = debianize (hackage "io-storage" `pflag` P.DebVersion "0.3-2" `tflag` P.DebVersion "0.3-5")
io_streams = debianize (git "https://github.com/snapframework/io-streams" [] {-hackage "io-streams"-})
iproute = debianize (hackage "iproute")
ircbot = debianize (hackage "ircbot")
irc = debianize (hackage "irc")
iso3166_country_codes = debianize (hackage "iso3166-country-codes")
ixset = debianize (git "https://github.com/Happstack/ixset.git" []) -- , debianize (hackage "ixset")
ixset_typed = debianize (hackage "ixset-typed") -- dependency of happstack-authenticate-2
jmacro = debianize (hackage "jmacro")
jmacro_rpc = broken $ debianize (hackage "jmacro-rpc")
jmacro_rpc_happstack = broken $ debianize (hackage "jmacro-rpc-happstack" `flag` P.SkipVersion "0.2.1") -- Really just waiting for jmacro-rpc
jquery = apt "sid" "jquery" `patch` $(embedFile "patches/jquery.diff") -- Revert to version 1.7.2+dfsg-3, version 1.7.2+dfsg-3.2 gives us a nearly empty jquery.min.js 
jquery_goodies = apt "sid" "jquery-goodies" `patch` $(embedFile "patches/jquery-goodies.diff")
             -- We want to stick with jqueryui-1.8 for now, so create
             -- packages with the version number embedded in the name.
jqueryui18 = darcs ("http://src.seereason.com/jqueryui18")
js_flot = debianize (hackage "js-flot")
js_jquery = debianize (hackage "js-jquery")
json = debianize (hackage "json") -- darcs "haskell-json" (repo ++ "/haskell-json")
juicyPixels = debianize (hackage "JuicyPixels")
jwt = debianize (hackage "jwt") -- dependency of happstack-authenticate-2
kan_extensions = debianize (hackage "kan-extensions")
keys = debianize (hackage "keys")
language_css = debianize (hackage "language-css" `flag` P.DebVersion "0.0.4.1-1~hackage1")
language_ecmascript = debianize (hackage "language-ecmascript")
language_haskell_extract = debianize (hackage "language-haskell-extract")
language_java = debianize (hackage "language-java" `flag` P.BuildDep "alex")
language_javascript = debianize (hackage "language-javascript"
                            `flag` P.BuildDep "happy"
                            `flag` P.BuildDep "alex"
                         )
largeword = debianize (hackage "largeword")
             -- No cabal file
             -- , debianize (git "haskell-logic-hs" "https://github.com/smichal/hs-logic")
         {-  , apt "wheezy" "haskell-leksah"
             , apt "wheezy" "haskell-leksah-server" -- for leksah -}
latex = debianize (hackage "latex")
lens = debianize (hackage "lens" `flag` P.CabalPin "4.8")
lens_family_core = debianize (hackage "lens-family-core")
lens_family = debianize (hackage "lens-family")
lens_family_th = debianize (hackage "lens-family-th")
    -- These five fail because representable-functors fails, it wasn't updated
    -- for the consolidation of comonad
    {-
    , debianize (hackage "representable-functors" {- `patch` $(embedFile "patches/representable-functors.diff") -})
    , debianize (hackage "representable-tries")
    , debianize (hackage "algebra")
    , debianize (hackage "universe" {- `patch` $(embedFile "patches/universe.diff") -})
    -}
libjs_jcrop = (baseRelease . release <$> get) >>= \ r ->
               case r of
                 Precise -> proc (apt "trusty" "libjs-jcrop")
                 _ -> zero
         {-
             , P.Package { P.spec = DebDir (Uri ("http://src.seereason.com/jcrop/Jcrop.tar.gz") "028feeb9b6415af3b7fd7d9471c92469") (Darcs ("http://src.seereason.com/jcrop-debian"))
                         , P.flags = [] }
         -}
libv8 = apt "sid" "libv8-3.14"
lifted_async = debianize (hackage "lifted-async")
lifted_base = debianize (hackage "lifted-base")
linear = debianize (hackage "linear")
list_extras = debianize (hackage "list-extras")
listLike = debianize (hackage "ListLike")
             -- Merged into ListLike-4.0
             -- , debianize (hackage "listlike-instances")
list_tries = debianize (hackage "list-tries" {- `patch` $(embedFile "patches/list-tries.diff") -}) -- version 0.5.2 depends on dlist << 0.7
loch_th = debianize (hackage "loch-th")
logic_classes = git "https://github.com/seereason/logic-classes" []
logic_TPTP = pure $ P.Package { P.spec = Debianize'' (Patch (Hackage "logic-TPTP") $(embedFile "patches/logic-TPTP.diff")) Nothing
                                , P.flags = [ P.BuildDep "alex", P.BuildDep "happy" ] }
             -- , apt "sid" "haskell-maybet"
logict = pure $ P.Package { P.spec = Debianize'' (Hackage "logict") Nothing, P.flags = [] }
loop = debianize (hackage "loop")
lucid = debianize (hackage "lucid")
maccatcher = debianize (hackage "maccatcher"
                            `pflag` P.DebVersion "2.1.5-3"
                            `tflag` P.DebVersion "2.1.5-5build1")
magic = debianize (hackage "magic" `flag` P.DevelDep "libmagic-dev")
         {-  , P.Package { P.spec = Quilt (Apt "wheezy" "magic-haskell") (Darcs ("http://src.seereason.com/magic-quilt"))
                         , P.flags = [] } -}
mainland_pretty = debianize (hackage "mainland-pretty")
makedev = apt "wheezy" "makedev"
markdown = debianize (hackage "markdown" {- `patch` $(embedFile "patches/markdown.diff") -})
markdown_unlit = debianize (hackage "markdown-unlit" `flag` P.CabalDebian ["--no-tests"])
matrix = debianize (hackage "matrix")
             -- , debianize (hackage "hlatex")
maybeT = debianize (hackage "MaybeT" `flag` P.DebVersion "1.2-6")
memoize = debianize (hackage "memoize")
memoTrie = debianize (hackage "MemoTrie")
mime = darcs ("http://src.seereason.com/haskell-mime")
mime_mail = debianize (git "https://github.com/snoyberg/mime-mail.git" [] `cd` "mime-mail")
mime_types = debianize (hackage "mime-types")
mirror = debianize (git "https://github.com/seereason/mirror" []
                      `flag` P.CabalDebian ["--executable", "debian-mirror"])
missingH = debianize (hackage "MissingH")
mmap = debianize (hackage "mmap")
mmorph = debianize (hackage "mmorph")
module_management = debianize (git "https://github.com/seereason/module-management" [] `flag` P.BuildDep "rsync")
monadCatchIO_mtl = debianize (hackage "MonadCatchIO-mtl" `patch` $(embedFile "patches/monadcatchio-mtl.diff"))
monadCatchIO_transformers = debianize (hackage "MonadCatchIO-transformers" `qflag` P.DebVersion "0.3.0.0-2build2")
monad_control = debianize (hackage "monad-control")
monadcryptorandom = debianize (hackage "monadcryptorandom")
monadLib = debianize (hackage "monadLib")
             -- Putting this in our repo can cause problems, because when it is
             -- installed some packages can't compile unless you add package
             -- qualifiers to their imports.  For this reason, when we run the
             -- autobuilder with the --lax flag we usually get a failure from
             -- some package that builds after monads-tf got installed.  On the
             -- other hand, without monads-tf we lose this dependency chain:
             -- monads-tf -> options -> fay.
monadlist = debianize (hackage "monadlist")
monad_logger = debianize (hackage "monad-logger")
monad_loops = debianize (hackage "monad-loops")
monad_parallel = debianize (hackage "monad-parallel")
monad_par = debianize (hackage "monad-par")
monad_par_extras = debianize (hackage "monad-par-extras")
monadRandom = debianize (hackage "MonadRandom")
monads_tf = debianize (hackage "monads-tf")
monad_task = debianize (hackage "monad-task")
monoid_transformer = debianize (hackage "monoid-transformer") -- apt (rel release "wheezy" "quantal") "haskell-monoid-transformer"
mtl = debianize (hackage "mtl")
mtl_compat = debianize (hackage "mtl-compat")
mtlparse = debianize (hackage "mtlparse")
multipart = debianize (hackage "multipart")
multiset = debianize (hackage "multiset")
murmur_hash = debianize (hackage "murmur-hash")
mwc_random = debianize (hackage "mwc-random")
nano_hmac = pure $ P.Package { P.spec = Debianize'' (Patch (Hackage "nano-hmac") $(embedFile "patches/nano-hmac.diff")) Nothing
                             , P.flags = [P.DebVersion "0.2.0ubuntu1"] }
nanospec = debianize (hackage "nanospec" `flag` P.CabalDebian ["--no-tests"]) -- avoid circular dependency nanospec <-> silently
nats = debianize (hackage "nats")
network_conduit = debianize (hackage "network-conduit")
network = debianize (hackage "network")
network_info = debianize (hackage "network-info")
network_uri = debianize (hackage "network-uri")
nodejs = skip (Reason "test failure on switch from 0.10.29~dfsg-1 to 0.10.29~dfsg-1.1") (apt "sid" "nodejs")
numeric_extras = debianize (hackage "numeric-extras" `tflag` P.DebVersion "0.0.3-1")
numInstances = debianize (hackage "NumInstances")
objectName = debianize (hackage "ObjectName")
oo_prototypes = debianize (hackage "oo-prototypes")
openGL = debianize (hackage "OpenGL"
                   `flag` P.DevelDep "libglu1-mesa-dev")
openGLRaw = debianize (hackage "OpenGLRaw"
                   `flag` P.DevelDep "libgl1-mesa-dev")
openid = debianize (hackage "openid" `patch` $(embedFile "patches/openid.diff"))
         {-  , P.Package { P.spec = Debianize (Patch (Hackage "openid") $(embedFile "patches/openid-ghc76.diff"))
                         , P.flags = [] } -}
openssl_streams = debianize (hackage "openssl-streams")
operational = pure $ P.Package { P.spec = Debianize'' (Hackage "operational") Nothing
                                , P.flags = [P.OmitLTDeps] }
         --    , debianize (hackage "options")
optparse_applicative = debianize (hackage "optparse-applicative")
ordered = debianize (hackage "ordered")
pandoc = debianize (-- git "https://github.com/jgm/pandoc" [Commit "d649acc146b9868fe23e0773654e5a95d88b156d"]
                    -- d649acc fails: hlibrary.setup: data/templates/default.html: does not exist
                    hackage "pandoc" `patch` $(embedFile "patches/pandoc.diff") -- hackage 1.13.2 is commit ccf081d32cc418e1d01f023059060aa22207d6e6
                           -- `flag` P.RelaxDep "libghc-pandoc-doc"
                           `flag` P.BuildDep "alex"
                           `flag` P.BuildDep "happy")
pandoc_types = debianize (hackage "pandoc-types")
parallel = debianize (hackage "parallel")
parseargs = debianize (hackage "parseargs")
             -- , apt (rel release "wheezy" "quantal") "haskell-parsec2" `patch` $(embedFile "patches/parsec2.diff")
parsec = debianize (hackage "parsec" `flag` P.ModifyAtoms (substitute "parsec2" "parsec3") `flag` P.CabalPin "3.1.8")
parse_dimacs = debianize (hackage "parse-dimacs")
parsers = debianize (hackage "parsers" {- `patch` $(embedFile "patches/parsers.diff") -})
pbkdf2 = debianize (hackage "PBKDF2")
             -- , apt (rel release "wheezy" "quantal") "haskell-pcre-light"
pcre_light = debianize (hackage "pcre-light"
                            `patch` $(embedFile "patches/pcre-light.diff")
                            `flag` P.DevelDep "libpcre3-dev")
pem = debianize (hackage "pem")
permutation = debianize (hackage "permutation")
pipes = debianize (hackage "pipes")
placeholders = debianize (hackage "placeholders")
plugins_auto = debianize (hackage "plugins-auto" `patch` $(embedFile "patches/plugins-auto.diff"))
plugins = debianize (hackage "plugins" `patch` $(embedFile "patches/plugins.diff"))
plugins_group = (named "plugins" . map APackage) =<<
    sequence [ plugins, plugins_ng, fsnotify, plugins_auto, happstack_plugins, web_plugins ]
plugins_group :: TSt P.Packages
plugins_ng = debianize (git "https://github.com/ddssff/plugins-ng" [])
po4a = apt "wheezy" "po4a"
pointed = debianize (hackage "pointed")
pointedlist = debianize (hackage "pointedlist")
polyparse = debianize (hackage "polyparse")
prelude_extras = debianize (hackage "prelude-extras")
prettyclass = debianize (hackage "prettyclass")
pretty_show = debianize (hackage "pretty-show" `flag` P.BuildDep "happy")
primitive = debianize (hackage "primitive" `flag` P.CabalPin "0.5.4.0") -- Waiting for newer lens
process_extras =
    debianize (git "https://github.com/seereason/process-extras" [])
                 `flag` P.ModifyAtoms (substitute "process-extras" "process-listlike")
processing = debianize (hackage "processing")
profunctors = debianize (hackage "profunctors"
                   `flag` P.ModifyAtoms (replacement "profunctors" "profunctors-extras"))
propLogic = debianize (git "https://github.com/ddssff/PropLogic" [])
pseudomacros = debianize (hackage "pseudomacros")
psQueue = wskip $
               debianize (hackage "PSQueue"
                            `pflag` P.DebVersion "1.1-2"
                            `qflag` P.DebVersion "1.1-2build2"
                            `sflag` P.DebVersion "1.1-1"
                            `tflag` P.DebVersion "1.1-4")
publicsuffixlist = debianize (hackage "publicsuffixlist" `tflag` P.DebVersion "0.1-1build4")
pureMD5 = debianize (hackage "pureMD5" `tflag` P.DebVersion "2.1.2.1-3build3")
pwstore_purehaskell = debianize (hackage "pwstore-purehaskell"
                            `flag` P.SkipVersion "2.1.2"
                            -- `patch` $(embedFile "patches/pwstore-purehaskell.diff")
                            -- `flag` P.DebVersion "2.1-1~hackage1"
                         )
             -- Retired
             -- , apt (rel release "wheezy" "quantal") "haskell-quickcheck1"
quickCheck = debianize (hackage "QuickCheck" `flag` P.BuildDep "libghc-random-prof" `flag` P.CabalDebian ["--no-tests"])
quickcheck_gent = debianize (hackage "QuickCheck-GenT")
quickcheck_instances = debianize (hackage "quickcheck-instances")
quickcheck_io = debianize (hackage "quickcheck-io")
quickCheck1 = debianize (hackage "QuickCheck" `flag` P.CabalPin "1.2.0.1" `flag` P.DebVersion "1.2.0.1-2" `flag` P.CabalDebian ["--no-tests"])
random = debianize (hackage "random" `flag` P.SkipVersion "1.0.1.3") -- 1.1.0.3 fixes the build for ghc-7.4.2 / base < 4.6
reducers = hack "reducers"
reflection = debianize (hackage "reflection") -- avoid rebuild
reform_blaze = debianize (git "https://github.com/Happstack/reform.git" [] `cd` "reform-blaze")
reform = debianize (git "https://github.com/Happstack/reform.git" [] `cd` "reform")
reform_hamlet = debianize (git "https://github.com/Happstack/reform.git" [] `cd` "reform-hamlet")
reform_happstack = debianize (git "https://github.com/Happstack/reform.git" [] `cd` "reform-happstack")
reform_hsp = debianize (git "https://github.com/Happstack/reform.git" [] `cd` "reform-hsp" `flag` P.BuildDep "hsx2hs")
regex_applicative = debianize (hackage "regex-applicative")
regex_base = debianize (hackage "regex-base"
                           `tflag` P.DebVersion "0.93.2-4"
                           `pflag` P.DebVersion "0.93.2-2") -- apt (rel release "wheezy" "quantal") "haskell-regex-base"
regex_compat = debianize (hackage "regex-compat"
                           `pflag` P.DebVersion "0.95.1-2"
                           `tflag` P.DebVersion "0.95.1-4") -- apt (rel release "wheezy" "quantal") "haskell-regex-compat"
regex_compat_tdfa = debianize (hackage "regex-compat-tdfa")
regex_pcre_builtin = debianize (hackage "regex-pcre-builtin"
                            -- Need to email Audrey Tang <audreyt@audreyt.org> about this.
                            `patch` $(embedFile "patches/regex-pcre-builtin.diff")
                            `flag` P.DevelDep "libpcre3-dev")
regex_posix = debianize (hackage "regex-posix" `tflag` P.DebVersion "0.95.2-3")
regexpr = debianize (hackage "regexpr" `flag` P.DebVersion "0.5.4-5build1")
regex_tdfa = debianize (hackage "regex-tdfa"
                        -- Although it might be nice to start using regex-tdfa-rc everywhere
                        -- we are using regex-tdfa, the cabal package names are different so
                        -- packages can't automatically start using regex-tdfa-rc.
                        `flag` P.ModifyAtoms (substitute "regex-tdfa" "regex-tdfa-rc"))
regex_tdfa_rc = debianize (hackage "regex-tdfa-rc"
                            `flag` P.ModifyAtoms (substitute "regex-tdfa-rc" "regex-tdfa"))
reified_records = debianize (hackage "reified-records" `patch` $(embedFile "patches/reified-records.diff"))
resourcet = debianize (hackage "resourcet")
rJson = debianize (hackage "RJson"
                            `patch` $(embedFile "patches/RJson.diff")
                            `wflag` P.DebVersion "0.3.7-1~hackage1")
rsa = debianize (hackage "RSA")
rss = debianize (hackage "rss" {- `patch` $(embedFile "patches/rss.diff") -})
safecopy = debianize (hackage "safecopy")
safe = debianize (hackage "safe")
safeSemaphore = debianize (hackage "SafeSemaphore")
sandi = debianize (hackage "sandi") -- replaces dataenc
sat = debianize (hackage "sat"
                            `patch` $(embedFile "patches/sat.diff")
                            `flag` P.DebVersion "1.1.1-1~hackage1")
scientific = debianize (hackage "scientific")
             -- , debianize (hackage "arithmoi" `flag` P.BuildDep "llvm-dev")
scotty = debianize (hackage "scotty")
seclib = debianize (darcs ("http://src.seereason.com/seclib"))
securemem = debianize (hackage "securemem")
seereason_base =
    debianize (git "https://github.com/seereason/seereason-base" [])
seereason_keyring = darcs ("http://src.seereason.com/seereason-keyring") `flag` P.UDeb "seereason-keyring-udeb"
seereason_ports = debianize (git "https://github.com/seereason/seereason-ports" [])
semigroupoids = debianize (hackage "semigroupoids"
                   `flag` P.ModifyAtoms (replacement "semigroupoids" "semigroupoid-extras"))
semigroups = debianize (hackage "semigroups")
sendfile = debianize (hackage "sendfile" `tflag` P.DebVersion "0.7.9-1")
setenv = debianize (hackage "setenv")
set_extra = darcs ("http://src.seereason.com/set-extra")
             -- I don't think we use this any more
             -- , debianize (darcs "haskell-old-exception" ("http://src.seereason.com/old-exception"))
set_monad = debianize (hackage "set-monad")
sha = debianize (hackage "SHA") -- apt (rel release "wheezy" "quantal") "haskell-sha"
shake = debianize (hackage "shake")
shakespeare = debianize (hackage "shakespeare")
shakespeare_js = debianize (hackage "shakespeare-js")
shellmate = hack "shellmate"
shelly = debianize (hackage "shelly")
showplease = debianize (git "https://github.com/ddssff/showplease" [])
silently = debianize (hackage "silently")
simple_sendfile = debianize (hackage "simple-sendfile")
singletons = debianize (hackage "singletons")
smallcheck = debianize (hackage "smallcheck")
smtpClient = debianize (hackage "SMTPClient")
socks = debianize (hackage "socks")
sourcemap = debianize (hackage "sourcemap")
spine = debianize (hackage "spine")
split = debianize (hackage "split" `tflag` P.DebVersion "0.2.2-1")
srcloc = debianize (hackage "srcloc")
stateVar = debianize (hackage "StateVar")
stb_image = debianize (hackage "stb-image")
stm_chans = debianize (hackage "stm-chans")
stm = debianize (hackage "stm")
streaming_commons = debianize (hackage "streaming-commons")
strict = debianize (hackage "strict"
                            `pflag` P.DebVersion "0.3.2-2"
                            `tflag` P.DebVersion "0.3.2-7") -- apt (rel release "wheezy" "quantal") "haskell-strict" -- for leksah
             -- , debianize (hackage "strict-concurrency" `wflag` P.DebVersion "0.2.4.1-2")
strict_io = debianize (hackage "strict-io") -- for GenI
stringable = debianize (hackage "stringable") -- this can be done with listlike-instances
stringbuilder = debianize (hackage "stringbuilder")
stringsearch = debianize (hackage "stringsearch")
sunroof_compiler = debianize (git "http://github.com/ku-fpg/sunroof-compiler" [] `patch` $(embedFile "patches/sunroof-compiler.diff"))
syb = debianize (hackage "syb")
syb_with_class = debianize (git "http://github.com/seereason/syb-with-class" []) -- Version 0.6.1.5 tries to derive typeable instances when building rjson, which is an error for ghc-7.8
syb_with_class_instances_text = broken $
               debianize (hackage "syb-with-class-instances-text"
                            `pflag` P.DebVersion "0.0.1-3"
                            `wflag` P.DebVersion "0.0.1-3"
                            `wflag` P.SkipVersion "0.0.1-3"
                            `tflag` P.DebVersion "0.0.1-6build1")
system_fileio = debianize (hackage "system-fileio")
system_filepath = debianize (hackage "system-filepath")
             -- , P.Package { P.spec = Debianize'' (Patch (Hackage "xml-enumerator") $(embedFile "patches/xml-enumerator.diff")) Nothing , P.flags = [] }
tagged = debianize (hackage "tagged")
tagshare = debianize (hackage "tagshare")
tagsoup = debianize (hackage "tagsoup")
tagstream_conduit = debianize (hackage "tagstream-conduit")
tar = debianize (hackage "tar")
         {-  -- This is built into ghc-7.8.3
             , debianize (hackage "terminfo"
                                      `flag` P.DevelDep "libncurses5-dev"
                                      `flag` P.DevelDep "libncursesw5-dev") -}
tasty = debianize (hackage "tasty")
tasty_hunit = debianize (hackage "tasty-hunit")
tasty_quickcheck = debianize (hackage "tasty-quickcheck")
tasty_smallcheck = debianize (hackage "tasty-smallcheck")
template_default = debianize (hackage "template-default" `patch` $(embedFile "patches/template-default.diff"))
temporary = debianize (hackage "temporary")
tensor = broken $ debianize (hackage "Tensor" `tflag` P.DebVersion "1.0.0.1-2")
test_framework = debianize (hackage "test-framework")
test_framework_hunit = debianize (hackage "test-framework-hunit" `tflag` P.DebVersion "0.3.0.1-1build4")
             -- Retired
             -- , debianize (hackage "test-framework-quickcheck")
test_framework_quickcheck2 = debianize (git "https://github.com/seereason/test-framework" [] {-hackage "test-framework-quickcheck2"-}
                                                `cd` "quickcheck2"
                                                {-`flag` P.SkipVersion "0.3.0.2"-})
test_framework_quickcheck = debianize (git "https://github.com/seereason/test-framework" [] {-hackage "test-framework-quickcheck2"-}
                                                `cd` "quickcheck"
                                                {-`flag` P.SkipVersion "0.3.0.2"-})
test_framework_smallcheck = debianize (hackage "test-framework-smallcheck")
test_framework_th = debianize (hackage "test-framework-th" `tflag` P.DebVersion "0.2.4-1build4")
             --
             -- , debianize (hackage "testpack" `patch` $(embedFile "patches/testpack.diff"))
testing_feat = debianize (hackage "testing-feat")
texmath = debianize (hackage "texmath")
text_binary = debianize (hackage "text-binary")
text = debianize (hackage "text" `flag` P.CabalDebian ["--cabal-flags", "-integer-simple"] `flag` P.CabalDebian ["--no-tests"])
text_icu = debianize (hackage "text-icu" `flag` P.DevelDep "libicu-dev")
text_show = debianize (hackage "text-show")
text_stream_decode = debianize (hackage "text-stream-decode" `patch` $(embedFile "patches/text-stream-decode.diff"))
tf_random = debianize (hackage "tf-random")
th_alpha = debianize (git "https://github.com/jkarni/th-alpha.git" [])
th_context = debianize (git "http://github.com/seereason/th-context" [])
th_desugar = debianize $ git "http://github.com/goldfirere/th-desugar" []
th_expand_syns = debianize (hackage "th-expand-syns")
-- th_instance_reification = debianize (git "https://github.com/seereason/th-instance-reification.git" [])
th_lift = debianize (git "https://github.com/seereason/th-lift" []) -- changes for template-haskell-2.10 and ghc-7.8
th_orphans = debianize (hackage "th-orphans")
threads = debianize (hackage "threads")
th_reify_many = debianize (hackage "th-reify-many")
time_compat = debianize (hackage "time-compat")
tinymce = apt "wheezy" "tinymce"
tls = debianize (hackage "tls")
            -- tls-extra deprecated in favor of tls
            -- , debianize (hackage "tls-extra" `patch` $(embedFile "patches/tls-extra.diff"))
transformers_base = debianize (hackage "transformers-base")
transformers_compat = debianize (hackage "transformers-compat"
                   `patch` $(embedFile "patches/transformers-compat.diff"))
    -- profuctors now includes profunctor-extras
transformers = debianize (hackage "transformers" `flag` P.CabalDebian [ "--debian-name-base", "transformers-4", "--cabal-flags", "-three" ])
transformers_free = debianize (hackage "transformers-free")
traverse_with_class = debianize (hackage "traverse-with-class")
trifecta = hack "trifecta"
tyb = skip (Reason "Needs update for current template-haskell") $ debianize (hackage "TYB")
type_eq = debianize (hackage "type-eq")
unbounded_delays = debianize (hackage "unbounded-delays")
unicode_names = debianize (hackage "unicode-names" `flag` P.DebVersion "3.2.0.0-1~hackage1")
unicode_properties = debianize (hackage "unicode-properties"
                            `patch` $(embedFile "patches/unicode-properties.diff")
                            `flag` P.DebVersion "3.2.0.0-1~hackage1")
unification_fd = debianize (hackage "unification-fd" `flag` P.SkipVersion "0.8.0")
union_find = debianize (hackage "union-find")
             -- , debianize (hackage "Elm")
             -- , debianize (hackage "elm-server" {- `patch` $(embedFile "patches/elm-server.diff") -})
uniplate = debianize (hackage "uniplate")
units = debianize (hackage "units")
unix_compat = debianize (hackage "unix-compat")
unix_time = debianize (hackage "unix-time" `flag` P.CabalDebian ["--no-run-tests"]) -- doctest assumes cabal build dir is dist
unixutils = debianize (git "https://github.com/seereason/haskell-unixutils" [])
unixutils_shadow = debianize (hackage "Unixutils-shadow")
unordered_containers = debianize (hackage "unordered-containers")
             -- Obsolete after ghc-6.10
             -- , debianize (hackage "utf8-prelude" `flag` P.DebVersion "0.1.6-1~hackage1")
             -- The GHC in wheezy conflicts with libghc-containers-dev, so we can't build this.
             -- , wonly $ debianize (hackage "containers")
urlencoded = debianize (hackage "urlencoded" `patch` $(embedFile "patches/urlencoded.diff"))
utf8_light = debianize (hackage "utf8-light")
utf8_string = debianize (hackage "utf8-string"
                            `flag` P.RelaxDep "hscolour"
                            `flag` P.RelaxDep "cpphs")
             -- , P.Package { P.spec = Apt (rel release "wheezy" "quantal") "haskell-utf8-string"
             --             , P.flags = [P.RelaxDep "hscolour", P.RelaxDep "cpphs"] }
utility_ht = debianize (hackage "utility-ht")
uuid = debianize (hackage "uuid")
uuid_types = debianize (hackage "uuid-types")
vacuum = debianize (hackage "vacuum" `flag` P.SkipVersion "2.1.0.1")
validation = debianize (hackage "Validation" `patch` $(embedFile "patches/validation.diff"))
value_supply = debianize (hackage "value-supply")
vault = debianize (hackage "vault")
vc_darcs = darcs ("http://src.seereason.com/vc-darcs")
vc_git_dired = git "https://github.com/ddssff/vc-git-dired" []
vector_algorithms = debianize (hackage "vector-algorithms")
vector_binary_instances = hack "vector-binary-instances"
vector = debianize (hackage "vector" {- `patch` $(embedFile "patches/vector.diff")-})
vector_space = debianize (hackage "vector-space")
virthualenv = pure $ P.Package { P.spec = Debianize'' (Patch (Hackage "virthualenv") $(embedFile "patches/virthualenv.diff")) Nothing
                                , P.flags =  [] }
void = debianize (hackage "void")
vty = debianize (hackage "vty")
wai_app_static = debianize (hackage "wai-app-static")
wai = debianize (hackage "wai" {- `patch` $(embedFile "patches/wai.diff") -})
wai_extra = debianize (hackage "wai-extra")
wai_logger = debianize (hackage "wai-logger")
wai_middleware_static = debianize (hackage "wai-middleware-static")
warp = skip (Reason "waiting for streaming-commons 0.1.10") $ debianize (hackage "warp")
webdriver = debianize (git "https://github.com/kallisti-dev/hs-webdriver.git" [Commit "0251579c4dd5aebc26a7ac5b300190f3370dbf9d" {- avoid rebuild -}])
web_encodings = pure $ P.Package { P.spec = Debianize'' (Patch (Hackage "web-encodings") $(embedFile "patches/web-encodings.diff")) Nothing
                                , P.flags = [] }
web_plugins = debianize (git "http://github.com/clckwrks/web-plugins" [] `cd` "web-plugins")
web_routes_boomerang = debianize (git "https://github.com/Happstack/web-routes.git" [] `cd` "web-routes-boomerang")
web_routes = debianize (git "https://github.com/Happstack/web-routes.git" [] `cd` "web-routes")
web_routes_happstack = debianize (git "https://github.com/Happstack/web-routes.git" [] `cd` "web-routes-happstack")
web_routes_hsp = debianize (git "https://github.com/Happstack/web-routes.git" [] `cd` "web-routes-hsp")
web_routes_mtl = debianize (git "https://github.com/Happstack/web-routes.git" [] `cd` "web-routes-mtl" `flag` P.DebVersion "0.20.1-1~hackage1")
web_routes_th = debianize (git "https://github.com/Happstack/web-routes.git" [] `cd` "web-routes-th")
            -- web_routes_transformers = debianize (git "https://github.com/Happstack/web-routes.git" [] `cd` "web-routes-transformers") -- requires transformers ==0.2.*
web_routes_wai = debianize (git "https://github.com/Happstack/web-routes.git" [] `cd` "web-routes-wai")
websockets = debianize (git "https://github.com/jaspervdj/websockets.git" [Commit "60705a97baa26888e3517a8bfe73e4b6e5d38a59" {- avoid rebuilds -}])
wl_pprint = debianize (hackage "wl-pprint")
wl_pprint_extras = debianize (hackage "wl-pprint-extras")
wl_pprint_text = debianize (hackage "wl-pprint-text")
             -- Our applicative-extras repository has several important patches.
word8 = debianize (hackage "word8")
word_trie = debianize (hackage "word-trie")
x509 = debianize (hackage "x509")
x509_store = debianize (hackage "x509-store")
x509_system = debianize (hackage "x509-system")
x509_validation = debianize (hackage "x509-validation")
xdg_basedir = debianize (hackage "xdg-basedir" `tflag` P.DebVersion "0.2.2-2")
xhtml = debianize (hackage "xhtml" `wflag` P.DebVersion "3000.2.1-1" `qflag` P.DebVersion "3000.2.1-1build2" `tflag` P.DebVersion "3000.2.1-4")
xml_conduit = debianize (hackage "xml-conduit")
xml = debianize (hackage "xml") -- apt (rel release "wheezy" "quantal") "haskell-xml"
xmlgen = debianize (hackage "xmlgen")
xmlhtml = debianize (hackage "xmlhtml")
xml_types = debianize (hackage "xml-types" `tflag` P.DebVersion "0.3.4-1")
xss_sanitize = debianize (hackage "xss-sanitize" `qflag` P.DebVersion "0.3.2-1build1")
yaml = debianize (hackage "yaml")
yaml_light = debianize (hackage "yaml-light"
                            `wflag` P.DebVersion "0.1.4-2"
                            `pflag` P.DebVersion "0.1.4-2"
                            `qflag` P.DebVersion "0.1.4-2build1"
                            `tflag` P.DebVersion "0.1.4-5build1")
yi = debianize (hackage "yi") -- requires alex >= 3.0.3
yi_language = debianize (hackage "yi-language" `flag` P.BuildDep "alex")
yi_rope = debianize (hackage "yi-rope")
zip_archive = debianize (hackage "zip-archive")
zlib_bindings = debianize (hackage "zlib-bindings")
zlib = debianize (hackage "zlib" `flag` P.DevelDep "zlib1g-dev")
zlib_enum = debianize (hackage "zlib-enum")
