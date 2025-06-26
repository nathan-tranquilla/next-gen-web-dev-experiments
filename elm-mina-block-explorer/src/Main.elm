module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, div, h1, p, a, text)
import Html.Attributes exposing (href)
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, (</>), oneOf, map, top, string)

-- MODEL
-- Each is a constructor of the Route type
type Route
    = Home
    | About
    | User String
    | NotFound

type alias Model =
    { route : Route
    , navKey : Nav.Key
    }

-- INIT
-- Initialize the model with the parsed route and the navigation key. Flags from javascript ignored
init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { route = parseUrl url, navKey = key }
    , Cmd.none
    )

-- Maps urls to Route type using Parser from elm/url
parseUrl : Url -> Route
parseUrl url =
    Parser.parse routeParser url
        |> Maybe.withDefault NotFound
        -- Examples:
        -- Url "/"        -> Just Home       -> Home
        -- Url "/about"   -> Just About      -> About
        -- Url "/user/123"-> Just (User "123") -> User "123"
        -- Url "/invalid" -> Nothing         -> NotFound

routeParser : Parser (Route -> Route) Route
routeParser =
    oneOf
        [ map Home top
        , map About (Parser.s "about")
        , map User (Parser.s "user" </> string)
        ]
-- oneOf: List (Parser (Route -> Route) Route) -> Parser (Route -> Route) Route
-- oneOf makes a list of parsers a single parser. Each parser maps a Url to a Route.

-- MSG
type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url

-- UPDATE (like useState + useNavigate)
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | route = parseUrl url }
            , Cmd.none
            )

-- VIEW (like JSX with <Routes>)
view : Model -> Browser.Document Msg
view model =
    { title = "Elm Router Example"
    , body =
        [ div []
            [ navBar
            , viewContent model.route
            ]
        ]
    }

navBar : Html Msg
navBar =
    div []
        [ a [ href "/" ] [ text "Home" ]
        , text " | "
        , a [ href "/about" ] [ text "About" ]
        , text " | "
        , a [ href "/user/123" ] [ text "User 123" ]
        ]

viewContent : Route -> Html Msg
viewContent route =
    case route of
        Home ->
            div []
                [ h1 [] [ text "Home" ]
                , p [] [ text "Welcome to the home page!" ]
                ]

        About ->
            div []
                [ h1 [] [ text "About" ]
                , p [] [ text "This is the about page." ]
                ]

        User userId ->
            div []
                [ h1 [] [ text ("User: " ++ userId) ]
                , p [] [ text ("Viewing profile for user ID: " ++ userId) ]
                ]

        NotFound ->
            div []
                [ h1 [] [ text "404 Not Found" ]
                , p [] [ text "This page does not exist." ]
                ]

-- MAIN
main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
