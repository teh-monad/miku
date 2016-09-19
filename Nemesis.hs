import System.Nemesis (run)
import System.Nemesis.DSL
import Air.Env ((-))
import Prelude hiding ((-))

main = run nemesis
nemesis = do

  clean
    [ "**/*.hi"
    , "**/*.o"
    , "manifest"
    , "test/hello_world"
    ]

  desc "dist"
  task "dist" - do
    sh "cabal clean"
    sh "cabal configure"
    sh "cabal sdist"

  desc "watch hs"
  task "watch-hs" - do
    sh "find . -name '*.hs' | entr runghc Nemesis.hs emacs-restart"

  desc "emacs-restart"
  task "emacs-restart" - do
    sh "emacsclient -e '(haskell-restart)'"

