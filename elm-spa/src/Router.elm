module Router exposing
    ( Config, define, createRoute, string, catchAll
    , Model, Msg(..), init, update, view, navigate, link
    )

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, (</>))

-- TYPES

type alias Config route model msg =
    { routes : List (RouteConfig route model msg)
    }

type alias RouteConfig route model msg =
    { path : Path route
    , routeValue : route
    , view : route -> model -> Html msg
    , update : msg -> route -> model -> (route, model, Cmd msg)
    , toUrl : route -> String
    }

type Path route
    = Static String
    | Dynamic (Parser (route -> route) route)
    | CatchAll

type alias Model route model msg =
    { currentRoute : route
    , navKey : Nav.Key
    , config : Config route model msg
    }

type Msg route
    = OnUrlRequest Browser.UrlRequest
    | OnUrlChange Url
    | Navigate route

-- API

define : List (RouteConfig route model msg) -> Config route model msg
define routeConfigs =
    { routes = routeConfigs }

createRoute : route -> { path : String, view : route -> model -> Html msg, update : msg -> route -> model -> (route, model, Cmd msg), toUrl : route -> String } -> RouteConfig route model msg
createRoute routeValue config =
    { path = Static config.path
    , routeValue = routeValue
    , view = config.view
    , update = config.update
    , toUrl = config.toUrl
    }

string : (String -> route) -> Path route
string constructor =
    Dynamic (Parser.map constructor Parser.string)

catchAll : Path route
catchAll =
    CatchAll

init : Config route model msg -> Url -> Nav.Key -> (Model route model msg, Cmd (Msg route))
init config url key =
    let
        matchedRoute = matchRoute config url
    in
    ( { currentRoute = matchedRoute, navKey = key, config = config }, Cmd.none )

update : Msg route -> Model route model msg -> model -> (Model route model msg, model, Cmd msg)
update msg model externalModel =
    case msg of
        OnUrlRequest (Browser.Internal url) ->
            let
                matchedRoute = matchRoute model.config url
            in
            ( { model | currentRoute = matchedRoute }, externalModel, Nav.pushUrl model.navKey (Url.toString url) )

        OnUrlRequest (Browser.External href) ->
            ( model, externalModel, Nav.load href )

        OnUrlChange url ->
            let
                matchedRoute = matchRoute model.config url
            in
            ( { model | currentRoute = matchedRoute }, externalModel, Cmd.none )

        Navigate targetRoute ->
            let
                url = routeToUrl model.config targetRoute
            in
            ( { model | currentRoute = targetRoute }, externalModel, Nav.pushUrl model.navKey url )

view : Model route model msg -> model -> Html msg
view model externalModel =
    case findRouteConfig model.config model.currentRoute of
        Just routeConfig -> routeConfig.view model.currentRoute externalModel
        Nothing -> Html.text "Route not found"

navigate : route -> Model route model msg -> Cmd (Msg route)
navigate targetRoute model =
    Nav.pushUrl model.navKey (routeToUrl model.config targetRoute)

link : route -> Config route model msg -> List (Html msg) -> Html msg
link targetRoute config content =
    Html.a [ Html.Attributes.href (routeToUrl config targetRoute), Html.Attributes.attribute "onclick" "event.preventDefault()" ] content

-- INTERNAL

matchRoute : Config route model msg -> Url -> route
matchRoute config url =
    let
        parser =
            Parser.oneOf
                (List.map
                    (\routeConfig ->
                        case routeConfig.path of
                            Static path ->
                                Parser.map routeConfig.routeValue (Parser.s path)
                            Dynamic dynamicParser ->
                                dynamicParser
                            CatchAll ->
                                Parser.map routeConfig.routeValue Parser.top
                    )
                    config.routes
                )
    in
    Parser.parse parser url
        |> Maybe.withDefault (List.head config.routes |> Maybe.map .routeValue |> Maybe.withDefault (Debug.todo "No routes defined in Config"))

findRouteConfig : Config route model msg -> route -> Maybe (RouteConfig route model msg)
findRouteConfig config targetRoute =
    List.filter (\routeConfig -> routeConfig.routeValue == targetRoute) config.routes
        |> List.head

routeToUrl : Config route model msg -> route -> String
routeToUrl config targetRoute =
    case findRouteConfig config targetRoute of
        Just routeConfig ->
            routeConfig.toUrl targetRoute
        Nothing ->
            "/"
