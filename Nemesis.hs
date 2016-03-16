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

  desc "watch hs"
  task "watch-hs" - do
    sh "find . -name '*.hs' | entr runghc Nemesis.hs emacs-save-and-restart"

  desc "emacs-save-and-restart"
  task "emacs-save-and-restart" - do
    sh "emacsclient -e '(haskell-save-and-restart)'"


  desc "emacs-save-and-reload"
  task "emacs-save-and-reload" - do
    sh "emacsclient -e '(haskell-save-and-reload)'"
