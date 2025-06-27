module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)
import Url
import Url.Parser as Parser exposing ((</>), Parser, s, string)
import Page.Home as Home
import Page.Blocks as Blocks
import Page.BlockSpotlight as BlockSpotlight

-- MODEL

type alias Model =
    { page : Page
    , key : Nav.Key
    , blocksModel : Blocks.Model -- Store Blocks.Model separately
    }

type Page
    = HomePage
    | BlocksPage
    | BlockSpotlightPage String

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( page, cmd ) =
            case parseUrl url of
                HomePage ->
                    ( HomePage, Cmd.none )
                BlocksPage ->
                    let
                        ( blocksModel, blocksCmd ) = Blocks.init ()
                    in
                    ( BlocksPage, Cmd.map BlocksMsg blocksCmd )
                BlockSpotlightPage statehash ->
                    ( BlockSpotlightPage statehash, Cmd.none )
    in
    ( { page = page, key = key, blocksModel = Blocks.initModel }
    , cmd
    )

-- UPDATE

type Msg
    = UrlChanged Url.Url
    | BlocksMsg Blocks.Msg
    | NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( UrlChanged url, _ ) ->
            let
                ( page, cmd ) =
                    case parseUrl url of
                        HomePage ->
                            ( HomePage, Cmd.none )
                        BlocksPage ->
                            let
                                ( blocksModel, blocksCmd ) = Blocks.init ()
                            in
                            ( BlocksPage, Cmd.map BlocksMsg blocksCmd )
                        BlockSpotlightPage statehash ->
                            ( BlockSpotlightPage statehash, Cmd.none )
            in
            ( { model | page = page }
            , cmd
            )

        ( BlocksMsg blocksMsg, BlocksPage ) ->
            let
                ( updatedBlocksModel, cmd ) = Blocks.update blocksMsg model.blocksModel
            in
            ( { model | blocksModel = updatedBlocksModel }
            , Cmd.map BlocksMsg cmd
            )

        ( NoOp, _ ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )

-- ROUTING

parseUrl : Url.Url -> Page
parseUrl url =
    case Parser.parse parser url of
        Just HomePage ->
            HomePage
        Just BlocksPage ->
            BlocksPage
        Just (BlockSpotlightPage statehash) ->
            BlockSpotlightPage statehash
        Nothing ->
            HomePage

parser : Parser (Page -> a) a
parser =
    Parser.oneOf
        [ Parser.map HomePage Parser.top
        , Parser.map BlocksPage (s "blocks")
        , Parser.map BlockSpotlightPage (s "blocks" </> string)
        ]

-- VIEW

view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [] [ text "Elm App" ]
        , viewPage model.page model.blocksModel
        ]

viewPage : Page -> Blocks.Model -> Html Msg
viewPage page blocksModel =
    case page of
        HomePage ->
            Home.view
        BlocksPage ->
            Html.map BlocksMsg (Blocks.view blocksModel)
        BlockSpotlightPage statehash ->
            BlockSpotlight.view statehash

-- MAIN

main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = \model -> { title = "Elm App", body = [ view model ] }
        , update = update
        , subscriptions = always Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = always NoOp
        }
