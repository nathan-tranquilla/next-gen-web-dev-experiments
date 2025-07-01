module Routes exposing (Route(..), routes)

import AppModel
import Router
import Html exposing (Html)
import Page.Home as Home
import Page.Blocks as Blocks
import Page.BlockSpotlight as BlockSpotlight
import Url.Parser as Parser exposing ((</>))

type Route
    = HomePage
    | BlocksPage
    | BlockSpotlightPage String

routes : Router.Config Route AppModel.Model AppModel.Msg
routes =
    Router.define HomePage
        [ Router.createRoute HomePage
            { path = ""
            , view = \_ _ -> Home.view
            , update = \msg r appModel ->
                case msg of
                    AppModel.BlocksMsg _ ->
                        ( r, appModel, Cmd.none )
                    -- _ -> ( r, appModel, Cmd.none )
            , toUrl = \_ -> "/"
            }
        , Router.createRoute BlocksPage
            { path = "blocks"
            , view = \_ appModel -> Html.map AppModel.BlocksMsg (Blocks.view appModel.blocks)
            , update = \msg r appModel ->
                case msg of
                    AppModel.BlocksMsg blocksMsg ->
                        let
                            ( updatedBlocksModel, cmd ) = Blocks.update blocksMsg appModel.blocks
                        in
                        ( r, { appModel | blocks = updatedBlocksModel }, Cmd.map AppModel.BlocksMsg cmd )
                    -- _ -> ( r, appModel, Cmd.none )
            , toUrl = \_ -> "/blocks"
            }
        ]
