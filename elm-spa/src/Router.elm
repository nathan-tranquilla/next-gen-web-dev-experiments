module Router exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>))
import String
import RouteConfig exposing (RouterConfig, RouteConfig, Path(..))
import Cmd.Extra exposing (perform)

type alias Model model msg =
    { currentPath : String
    , pathParams : List String
    , navKey : Nav.Key
    , config : RouterConfig model msg
    , url: Url
    }

type Msg
    = OnUrlRequest Browser.UrlRequest
    | OnUrlChange Url
    | Navigate String

findRouteConfig : RouterConfig model msg -> Url -> Maybe (RouteConfig model msg)
findRouteConfig config url =
    List.filter
        (\routeConfig ->
            case routeConfig.path of
                Static p -> p == normalizePath url.path
                Dynamic dynamicParser ->
                    let
                        parsed = Parser.parse dynamicParser url
                    in
                    Maybe.map (always True) parsed |> Maybe.withDefault False
                CatchAll -> True
        )
        config.routes
        |> List.head

pathToUrl : String -> String
pathToUrl path =
    "/" ++ path

normalizePath : String -> String
normalizePath path =
    path
        |> String.dropLeft (if String.startsWith "/" path then 1 else 0)
        |> String.dropRight (if String.endsWith "/" path then 1 else 0)

parsePathParams : RouterConfig model msg -> Url -> List String
parsePathParams config url =
    let
        normalizedPath = normalizePath url.path
        findParams routeConfig acc =
            case acc of
                Just params -> Just params
                Nothing ->
                    case routeConfig.path of
                        Static _ -> Nothing
                        Dynamic dynamicParser ->
                            Parser.parse dynamicParser { url | path = "/" ++ normalizedPath }
                                |> Maybe.map (\param -> [ param ])
                        CatchAll -> Nothing
    in
    List.foldl findParams Nothing config.routes
        |> Maybe.withDefault []

define : String -> List (RouteConfig model msg) -> RouterConfig model msg
define defaultPath routeConfigs =
    { routes = routeConfigs
    , defaultPath = defaultPath
    }

init : RouterConfig model msg -> Url -> Nav.Key -> ( Model model msg, Cmd Msg )
init config url key =
    let
        matchedPath = matchRoute config url
        pathParams = parsePathParams config url
    in
    ( { currentPath = matchedPath, pathParams = pathParams, navKey = key, config = config, url = url }, Cmd.none )

update : Msg -> Model model msg -> model -> ( Model model msg, model, Cmd Msg )
update msg routerModel appModel =
    case msg of
        OnUrlRequest (Browser.Internal url) ->
            let
                matchedPath = matchRoute routerModel.config url
                pathParams = parsePathParams routerModel.config url
            in
            ( { routerModel | currentPath = matchedPath, pathParams = pathParams, url = url }, appModel, Nav.pushUrl routerModel.navKey (pathToUrl matchedPath) )

        OnUrlRequest (Browser.External href) ->
            ( routerModel, appModel, Nav.load href )

        OnUrlChange url ->
            let
                matchedPath = matchRoute routerModel.config url
                pathParams = parsePathParams routerModel.config url
            in
            ( { routerModel | currentPath = matchedPath, pathParams = pathParams, url = url }, appModel, perform (Navigate matchedPath) )
        _ -> (routerModel, appModel, Cmd.none)

view : Model model msg -> model -> Html msg
view routerModel appModel =
    case findRouteConfig routerModel.config routerModel.url of
        Just routeConfig -> routeConfig.view appModel
        Nothing -> Html.text "Route not found"

navigate : String -> Model model msg -> Cmd Msg
navigate targetPath model =
    Nav.pushUrl model.navKey (pathToUrl targetPath)

link : String -> RouterConfig model msg -> List (Html Msg) -> Html Msg
link path _ content =
    Html.a [ Html.Attributes.href (pathToUrl path), Html.Attributes.attribute "onclick" "event.preventDefault()" ] content

matchRoute : RouterConfig model msg -> Url -> String
matchRoute config url =
    let
        normalizedPath = normalizePath url.path
        parser =
            Parser.oneOf
                (List.map
                    (\routeConfig ->
                        case routeConfig.path of
                            Static path ->
                                if path == "" then
                                    Parser.map path Parser.top
                                else
                                    Parser.map path (Parser.s path)
                            Dynamic dynamicParser ->
                                Parser.map (always normalizedPath) dynamicParser
                            CatchAll ->
                                Parser.map normalizedPath Parser.top
                    )
                    config.routes
                )
        parsedPath = Parser.parse parser { url | path = normalizedPath }
    in
    parsedPath
        |> Maybe.withDefault config.defaultPath
