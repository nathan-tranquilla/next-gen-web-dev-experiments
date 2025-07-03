module RouterTest exposing (suite)

import Expect
import Test exposing (..)
import Router exposing (findRouteConfig)
import RouteConfig exposing (Path(..))
import Page.Blocks as Blocks
import Page.Home as Home
import Router
import Url exposing (Protocol(..))

suite : Test
suite =
    describe "Router"
        [ describe "findRouteConfig"
            [ test "matches '' to HomePage route" <|
                \_ ->
                    let
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig ]
                    in
                    Expect.equal (Just Home.routeConfig) (findRouteConfig config "")
            , test "matches 'blocks' to BlocksPage route" <|
                \_ ->
                    let
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig ]
                    in
                    Expect.equal (Just Blocks.routeConfig) (findRouteConfig config "blocks")
            , test "returns Nothing for unknown path" <|
                \_ ->
                    let
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig ]
                    in
                    Expect.equal Nothing (findRouteConfig config "unknown")
            ]
        , describe "matchRoute"
            [ test "matches / to HomePage" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig ]
                        matchedRoute = Router.matchRoute config url
                    in
                    Expect.equal "" matchedRoute
            , test "matches /blocks to BlocksPage" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "/blocks", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig ]
                        matchedRoute = Router.matchRoute config url
                    in
                    Expect.equal "blocks" matchedRoute
            , test "matches /blocks/ to BlocksPage" <|
                \_ ->
                    let
                        url = { protocol = Url.Http, host = "localhost", port_ = Just 8000, path = "/blocks/", query = Nothing, fragment = Nothing }
                        config = Router.define "" [ Home.routeConfig, Blocks.routeConfig ]
                        matchedRoute = Router.matchRoute config url
                    in
                    Expect.equal "blocks" matchedRoute
            ]
        ]
