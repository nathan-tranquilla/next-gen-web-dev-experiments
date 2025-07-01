module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Router
import Html exposing (Html, div, h1, nav, text)
import Html.Attributes exposing (class)
import Page.Blocks as Blocks
import Routes exposing (Route(..), Msg(..), routes)
import Url exposing (Url)

type alias Model =
    { router : Router.Model Route Blocks.Model Routes.Msg
    , blocksModel : Blocks.Model
    }


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = RouterMsg << Router.OnUrlRequest
        , onUrlChange = RouterMsg << Router.OnUrlChange
        }

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init _ url key =
    let

        (routerModel, routerCmd) = Router.init routes url key
        (blocksModel, blocksCmd) = Blocks.init ()
    in
    ( { router = routerModel, blocksModel = blocksModel }
    , Cmd.batch
        [ Cmd.map RouterMsg routerCmd
        , Cmd.map BlocksMsg blocksCmd
        ]
    )


view : Model -> Browser.Document Msg
view model =
    { title = "Elm App"
    , body =
        [ div [ class "container" ]
            [ h1 [] [ text "Elm App" ]
            , nav []
                [ Router.link HomePage routes [ text "Home" ]
                , text " | "
                , Router.link BlocksPage routes [ text "Blocks" ]
                ]
            , Router.view model.router model.blocksModel
            ]
        ]
    }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        RouterMsg routerMsg ->
            let
                (newRouter, newBlocksModel, routerCmd) = Router.update routerMsg model.router model.blocksModel
            in
            ( { model | router = newRouter, blocksModel = newBlocksModel }, routerCmd )

        BlocksMsg blocksMsg ->
            let
                (updatedBlocksModel, blocksCmd) = Blocks.update blocksMsg model.blocksModel
            in
            ( { model | blocksModel = updatedBlocksModel }, Cmd.map BlocksMsg blocksCmd )
