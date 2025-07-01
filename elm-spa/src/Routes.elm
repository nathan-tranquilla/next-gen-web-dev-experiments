module Routes exposing (Route(..), Msg(..), routes)

import Router as Router
import Html
import Page.Home as Home
import Page.Blocks as Blocks
-- import Page.BlockSpotlight as BlockSpotlight
import Url.Parser exposing ((</>))

type Route
    = HomePage
    | BlocksPage
    | BlockSpotlightPage String

type Msg
    = RouterMsg (Router.Msg Route)
    | BlocksMsg Blocks.Msg

routes : Router.Config Route Blocks.Model Msg
routes =
    Router.define
        [ Router.createRoute HomePage
            { path = ""
            , view = \_ _ -> Home.view
            , update = \msg r blocksModel ->
                case msg of
                    BlocksMsg _ ->
                        (r, blocksModel, Cmd.none)
                    _ -> (r, blocksModel, Cmd.none)
            , toUrl = \_ -> "/"
            }
        , Router.createRoute BlocksPage
            { path = "blocks"
            , view = \_ blocksModel -> Html.map BlocksMsg (Blocks.view blocksModel)
            , update = \msg r blocksModel ->
                case msg of
                    BlocksMsg blocksMsg ->
                        let
                            (updatedBlocksModel, cmd) = Blocks.update blocksMsg blocksModel
                        in
                        (r, updatedBlocksModel, Cmd.map BlocksMsg cmd)
                    _ -> (r, blocksModel, Cmd.none)
            , toUrl = \_ -> "/blocks"
            }
            , Router.createRoute HomePage
                { path = ""
                , view = \_ _ -> Html.text "Not Found"
                , update = \_ r blocksModel -> (r, blocksModel, Cmd.none)
                , toUrl = \_ -> "/"
                }
        -- , Router.createRoute (BlockSpotlightPage "")
        --     { path = "blocks" </> Router.string BlockSpotlightPage
        --     , view = \route _ ->
        --         case route of
        --             BlockSpotlightPage statehash -> BlockSpotlight.view statehash
        --             _ -> Html.text "Invalid route"
        --     , update = \msg r blocksModel ->
        --         case msg of
        --             BlocksMsg _ ->
        --                 (r, blocksModel, Cmd.none)
        --             _ -> (r, blocksModel, Cmd.none)
        --     , toUrl = \route ->
        --         case route of
        --             BlockSpotlightPage statehash -> "/blocks/" ++ statehash
        --             _ -> "/"
        --     }
        ]
