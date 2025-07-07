module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser as Parser exposing ((</>))
import Url.Parser as Parser
import Page.Home
import Page.Blocks
import Page.BlockSpotlight
import Debug

-- MAIN


main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }


-- MODEL


type alias Model =
  { key : Nav.Key
  , url : Url.Url
  , currentRoute: Route
  , blocksPage: Page.Blocks.Model
  }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        parsedRoute = Parser.parse routeParser url |> Maybe.withDefault Home
        cmd = case parsedRoute of
            Blocks ->
                Page.Blocks.getBlocks
            _ -> 
                Cmd.none
    in
    ( Model key url parsedRoute Page.Blocks.initModel, Cmd.map BlocksPageMsg cmd )

-- ROUTE CONFIG
type Route
  = Home
  | Blocks
  | BlockSpotlight String

routeParser : Parser.Parser (Route -> a) a
routeParser =
  Parser.oneOf
    [ Parser.map Home Parser.top
    , Parser.map Blocks (Parser.s "blocks")
    , Parser.map BlockSpotlight (Parser.s "blocks" </> Parser.string) -- /blocks/3NLoLCvmERrBmgcHufCScQKr19jr2PtN9CzvDpPHr13S8YrDnvR8
    ]


-- UPDATE


type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | BlocksPageMsg Page.Blocks.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    -- let
    --     _ = Debug.log "model before update" model
    --     _ = Debug.log "Received message" msg
    -- in
  case msg of
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model , Nav.pushUrl model.key (Url.toString url) )

        Browser.External href ->
          ( model, Nav.load href )

    UrlChanged url ->  
        let
            parsedRoute = Parser.parse routeParser url |> Maybe.withDefault Home
            cmd = case parsedRoute of
                Blocks ->
                    Page.Blocks.getBlocks
                _ -> 
                    Cmd.none
        in
        ( { model | url = url, currentRoute = parsedRoute }
        , cmd |> Cmd.map BlocksPageMsg
        )
    BlocksPageMsg blocksMsg ->
            let
                (updatedBlocksModel, blocksCmd) =
                    Page.Blocks.update blocksMsg model.blocksPage
            in
            ( { model | blocksPage = updatedBlocksModel }
            , Cmd.map BlocksPageMsg blocksCmd
            )
        


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "MINA Blockchain Explorer"
    , body =
        [ div [ class "my-2 flex flex-col justify-start align-center w-full" ]
            [ h1 [ class "text-xl flex justify-center" ] [ text "MINA Blockchain Explorer" ]
            , nav [ class "flex justify-center my-6" ]
                [ a [ href "/", class "text-blue-600 mx-2 hover:underline" ] [ text "Home" ]
                , a [ href "/blocks", class "text-blue-600 mx-2 hover:underline" ] [ text "Blocks" ]
                ]
            ]
        , viewRoute model.currentRoute model
        ]
    }

viewRoute : Route -> Model -> Html Msg
viewRoute route model =
    case route of
        Blocks -> Page.Blocks.view model.blocksPage
        Home -> Page.Home.view
        BlockSpotlight stateHash -> Page.BlockSpotlight.view stateHash
    

viewLink : String -> String -> Html msg
viewLink label path =
  li [] [ a [ href path ] [ text label ] ]
