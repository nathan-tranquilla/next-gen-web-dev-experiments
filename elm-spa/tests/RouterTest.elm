module RouterTest exposing (suite)

import Expect
import Test exposing (..)
import Router exposing (findRouteConfig)
import RouteConfig exposing (Path(..))
import Page.Blocks as Blocks
import Page.Home as Home
import Page.BlockSpotlight as BlockSpotlight
import Url exposing (Protocol(..))

suite : Test
suite =
    describe "Router"
        [ describe "findRouteConfig"
            [ test "matches '' to HomePage route" <|
                \_ ->
                    let
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                    in
                    Expect.equal (Just Home.routeConfig) (findRouteConfig config "")
            , test "matches 'blocks' to BlocksPage route" <|
                \_ ->
                    let
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                    in
                    Expect.equal (Just Blocks.routeConfig) (findRouteConfig config "blocks")
            , test "matches 'blocks/some-statehash' to BlockSpotlight route" <|
                \_ ->
                    let
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                    in
                    Expect.equal (Just BlockSpotlight.routeConfig) (findRouteConfig config "blocks/some-statehash")
            , test "returns Nothing for unknown path" <|
                \_ ->
                    let
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                    in
                    Expect.equal Nothing (findRouteConfig config "unknown")
            ]
        , describe "normalizePath"
            [ test "normalizes '/blocks/' to 'blocks'" <|
                \_ ->
                    Expect.equal "blocks" (Router.normalizePath "/blocks/")
            , test "normalizes '/blocks' to 'blocks'" <|
                \_ ->
                    Expect.equal "blocks" (Router.normalizePath "/blocks")
            , test "normalizes 'blocks/' to 'blocks'" <|
                \_ ->
                    Expect.equal "blocks" (Router.normalizePath "blocks/")
            , test "normalizes 'blocks' to 'blocks'" <|
                \_ ->
                    Expect.equal "blocks" (Router.normalizePath "blocks")
            , test "normalizes '/blocks/state_hash/' to 'blocks/state_hash'" <|
                \_ ->
                    Expect.equal "blocks/state_hash" (Router.normalizePath "/blocks/state_hash/")
            , test "normalizes '/blocks/state_hash' to 'blocks/state_hash'" <|
                \_ ->
                    Expect.equal "blocks/state_hash" (Router.normalizePath "/blocks/state_hash")
            , test "normalizes 'blocks/state_hash/' to 'blocks/state_hash'" <|
                \_ ->
                    Expect.equal "blocks/state_hash" (Router.normalizePath "blocks/state_hash/")
            , test "normalizes 'blocks/state_hash' to 'blocks/state_hash'" <|
                \_ ->
                    Expect.equal "blocks/state_hash" (Router.normalizePath "blocks/state_hash")
            ]
        , describe "matchRoute"
            [ test "matches / to HomePage" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                        matchedRoute = Router.matchRoute config url
                    in
                    Expect.equal "" matchedRoute
            , test "matches /blocks to BlocksPage" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "/blocks", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                        matchedRoute = Router.matchRoute config url
                    in
                    Expect.equal "blocks" matchedRoute
            , test "matches /blocks/ to BlocksPage" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "/blocks/", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                        matchedRoute = Router.matchRoute config url
                    in
                    Expect.equal "blocks" matchedRoute
            , test "matches /blocks/some-statehash to BlockSpotlight" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "/blocks/some-statehash", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                        matchedRoute = Router.matchRoute config url
                    in
                    Expect.equal "blocks/some-statehash" matchedRoute
            , test "matches /blocks/another-statehash to BlockSpotlight" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "/blocks/another-statehash", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                        matchedRoute = Router.matchRoute config url
                    in
                    Expect.equal "blocks/another-statehash" matchedRoute
            ]
        , describe "parsePathParams"
            [ test "parses / to empty list" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                    in
                    Expect.equal [] (Router.parsePathParams config url)
            , test "parses /blocks to empty list" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "/blocks", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                    in
                    Expect.equal [] (Router.parsePathParams config url)
            , test "parses /blocks/some-statehash to ['some-statehash']" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "/blocks/some-statehash", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                    in
                    Expect.equal ["some-statehash"] (Router.parsePathParams config url)
            , test "parses /unknown to empty list" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "/unknown", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig, BlockSpotlight.routeConfig ]
                    in
                    Expect.equal [] (Router.parsePathParams config url)
            ]
        ]
