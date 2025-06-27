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
    , key : Nav.Key -- Add Nav.Key to the model to store it
    }


type Page
    = Home
    | Blocks
    | BlockSpotlight String


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { page = parseUrl url
      , key = key
      }
    , Cmd.none
    )


-- UPDATE

type Msg
    = UrlChanged Url.Url
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            ( { model | page = parseUrl url }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


-- ROUTING

parseUrl : Url.Url -> Page
parseUrl url =
    case Parser.parse parser url of
        Just page ->
            page

        Nothing ->
            Home


parser : Parser (Page -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Blocks (s "blocks")
        , Parser.map BlockSpotlight (s "blocks" </> string)
        ]


-- VIEW

view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [] [ text "Elm App" ]
        , viewPage model.page
        ]


viewPage : Page -> Html Msg
viewPage page =
    case page of
        Home ->
            Home.view

        Blocks ->
            Blocks.view

        BlockSpotlight statehash ->
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
