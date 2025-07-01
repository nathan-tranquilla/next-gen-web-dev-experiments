module Main exposing (main)

import AppModel as AppModel exposing (..)
import Browser
import Browser.Navigation as Nav
import Router
import Html exposing (Html, div, h1, nav, text)
import Html.Attributes exposing (class)
import Routes exposing (Route(..), routes)
import Url exposing (Url)

type alias Model =
    { router : Router.Model Route AppModel.Model AppModel.Msg
    , appModel : AppModel.Model
    }

type Msg
    = RouterMsg (Router.Msg Route)
    | AppMsg AppModel.Msg

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

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( routerModel, routerCmd ) = Router.init routes url key
        ( appModel, appCmd ) = AppModel.init ()
    in
    ( { router = routerModel, appModel = appModel }
    , Cmd.batch
        [ Cmd.map RouterMsg routerCmd
        , Cmd.map AppMsg appCmd
        ]
    )

view : Model -> Browser.Document Msg
view model =
    { title = "Elm App"
    , body =
        [ div [ class "container" ]
            [ h1 [] [ text "Elm App" ]
            , nav []
                [ Router.link HomePage routes [ text "Home" ] |> Html.map AppMsg
                , text " | "
                , Router.link BlocksPage routes [ text "Blocks" ] |> Html.map AppMsg
                ]
            , Router.view model.router model.appModel |> Html.map AppMsg
            ]
        ]
    }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouterMsg routerMsg ->
            let
                ( newRouter, newAppModel, routerCmd ) = Router.update routerMsg model.router model.appModel
            in
            ( { model | router = newRouter, appModel = newAppModel }, Cmd.map AppMsg routerCmd )

        AppMsg appMsg ->
            let
                ( newAppModel, appCmd ) = AppModel.update appMsg model.appModel
            in
            ( { model | appModel = newAppModel }, Cmd.map AppMsg appCmd )
