module RouterTest exposing (suite)

import AppModel
import Expect
import Page.Blocks as Blocks
import Router exposing (matchRoute)
import Routes exposing (Route(..))
import Test exposing (..)
import Url exposing (Url, Protocol(..))

suite : Test
suite =
    describe "Router.matchRoute"
        [ test "matches / to HomePage" <|
            \_ ->
                let
                    url = Url.fromString "http://localhost:8000/" |> Maybe.withDefault (Url Http "localhost" (Just 8000) "" Nothing Nothing)
                    config = Routes.routes
                    matchedRoute = Router.matchRoute config url
                in
                Expect.equal HomePage matchedRoute

        , test "matches /blocks to BlocksPage" <|
            \_ ->
                let
                    url = Url.fromString "http://localhost:8000/blocks" |> Maybe.withDefault (Url Http "localhost" (Just 8000) "/blocks" Nothing Nothing)
                    config = Routes.routes
                    matchedRoute = Router.matchRoute config url
                in
                Expect.equal BlocksPage matchedRoute

        , test "matches /blocks/ to BlocksPage" <|
            \_ ->
                let
                    url = Url.fromString "http://localhost:8000/blocks/" |> Maybe.withDefault (Url Http "localhost" (Just 8000) "/blocks/" Nothing Nothing)
                    config = Routes.routes
                    matchedRoute = Router.matchRoute config url
                in
                Expect.equal BlocksPage matchedRoute


        ]
