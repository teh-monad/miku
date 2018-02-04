# miku

A tiny web dev DSL

## Example

    {-# LANGUAGE OverloadedStrings #-}

    import           Network.Miku
    import           Network.Wai.Handler.Warp (run)

    main :: IO ()
    main = run 3000 . miku $ get "/" (text "miku power")

## Quick reference

<https://github.com/nfjinjing/miku/blob/master/test/RouteExample.hs>

## Routes

### Verbs

    {-# LANGUAGE OverloadedStrings #-}

    import Network.Miku
    import Network.Miku.Utils ((-))
    import Network.Wai.Handler.Warp (run)
    import Prelude hiding ((-))

    main = run 3000 . miku - do

      get "/" - do
        -- something for a get request

      post "/" - do
        -- for a post request

      put "/" - do
        -- put ..

      delete "/" - do
        -- ..

### Captures

    get "/say/:user/:message" - do
      text . show =<< captures

    -- /say/miku/hello will output
    -- [("user","miku"),("message","hello")]


## WAI integration

### Use WAI middleware

    import Network.Wai.Middleware.RequestLogger

    middleware logStdout

### Convert miku into a WAI application

    -- in Network.Miku.Engine

    miku :: MikuMonad -> Application


## Hints

* It's recommended to use your own html combinator / template engine. Try DIY with, e.g. [moe](https://github.com/nfjinjing/moe).
* [Example view using custom html combinator (moe in this case)](https://github.com/nfjinjing/miku/blob/master/test/HTMLUsingMoe.hs)
* When inspecting the request, use `ask` defined in `ReaderT` monad to get the `Request`, then use helper methods for `wai` to query it.
* `Response` is in `StateT`, `html` and `text` are simply helper methods that update the state, i.e. setting the response body, content-type, etc.
* You do need to understand monad transformers to reach the full power of `miku`.

## Reference

* miku is inspired by [Rack](http://rack.rubyforge.org), [Rails](http://rubyonrails.org), [Ramaze](http://ramaze.net), [Happstack](http://happstack.com/) and [Sinatra](http://www.sinatrarb.com/).
