module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Router
import Html exposing (div, h1, nav, text)
import Html.Attributes exposing (class)
import RouteConfig exposing (RouterConfig, Path(..))
import Url exposing (Url)
import Page.Blocks as Blocks
import Page.Home as Home
import Page.BlockSpotlight as BlockSpotlight
import Shared exposing (Model(..), Msg(..), BlocksMsg(..))

main : Program () Model Msg
main =
    let
        routeConfig =
            Router.define ""
                [ Home.routeConfig
                , Blocks.routeConfig
                , BlockSpotlight.routeConfig
                ]
    in
    Browser.application
        { init = init routeConfig
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = RouterMsg << Router.OnUrlRequest
        , onUrlChange = RouterMsg << Router.OnUrlChange
        }

init : RouterConfig Model Msg -> () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init routeConfig _ url key =
    let
        ( routerModel, routerCmd ) = Router.init routeConfig url key
        initCmd =
            if routerModel.currentPath == "blocks" then
                Cmd.map BlocksMsg Blocks.getBlocks
            else
                Cmd.none
    in
    ( Model { router = routerModel, blocks = Nothing }
    , Cmd.batch [ Cmd.map RouterMsg routerCmd, initCmd ]
    )

view : Model -> Browser.Document Msg
view (Model model) =
    { title = "MINA Blockchain Explorer"
    , body =
        [ div [ class "container" ]
            [ h1 [] [ text "MINA Blockchain Explorer" ]
            , nav []
                [ Router.link "" model.router.config [ text "Home" ] |> Html.map RouterMsg
                , text " | "
                , Router.link "blocks" model.router.config [ text "Blocks" ] |> Html.map RouterMsg
                ]
            , Router.view model.router (Model model)
            ]
        ]
    }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case msg of
        RouterMsg routerMsg ->
            let
                ( newRouter, _, routerCmd ) = Router.update routerMsg model.router (Model model)
            in
            case routerMsg of
                Router.Navigate "blocks" ->
                    ( Model { model | router = newRouter, blocks = Just Blocks.initModel }
                    , Cmd.batch [ Cmd.map RouterMsg routerCmd, Cmd.map BlocksMsg Blocks.getBlocks ]
                    )
                _ -> ( Model { model | router = newRouter }
                    , Cmd.map RouterMsg routerCmd
                    )

        BlocksMsg blocksMsg ->
            let
                ( newBlocksModel, blocksCmd ) =
                    case model.blocks of
                        Just blocksModel -> Blocks.update blocksMsg blocksModel
                        Nothing -> Blocks.update blocksMsg Blocks.initModel
            in
            ( Model { model | blocks = Just newBlocksModel }
            , Cmd.map BlocksMsg blocksCmd
            )
