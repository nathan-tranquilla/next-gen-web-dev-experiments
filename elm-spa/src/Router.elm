module Router exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>))
import String
import RouteConfig exposing (Config, RouteConfig, Path(..))
import Debug
import Cmd.Extra exposing (perform)

type alias Model model msg =
    { currentPath : String
    , pathParams : List String
    , navKey : Nav.Key
    , config : Config model msg
    }

type Msg
    = OnUrlRequest Browser.UrlRequest
    | OnUrlChange Url
    | Navigate String

findRouteConfig : Config model msg -> String -> Maybe (RouteConfig model msg)
findRouteConfig config path =
    List.filter
        (\routeConfig ->
            case routeConfig.path of
                Static p -> p == path
                Dynamic dynamicParser ->
                    let
                        parsed = Parser.parse dynamicParser { protocol = Url.Http, host = "", port_ = Nothing, path = "/" ++ path, query = Nothing, fragment = Nothing }
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

parsePathParams : Config model msg -> Url -> List String
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

define : String -> List (RouteConfig model msg) -> Config model msg
define defaultPath routeConfigs =
    { routes = routeConfigs
    , defaultPath = defaultPath
    }

init : Config model msg -> Url -> Nav.Key -> ( Model model msg, Cmd Msg )
init config url key =
    let
        matchedPath = matchRoute config url
        pathParams = parsePathParams config url
        _ = Debug.log "Router.init: pathParams" pathParams
    in
    ( { currentPath = matchedPath, pathParams = pathParams, navKey = key, config = config }, Cmd.none )

update : Msg -> Model model msg -> model -> ( Model model msg, model, Cmd Msg )
update msg routerModel appModel =
    case msg of
        OnUrlRequest (Browser.Internal url) ->
            let
                matchedPath = matchRoute routerModel.config url
                pathParams = parsePathParams routerModel.config url
            in
            ( { routerModel | currentPath = matchedPath, pathParams = pathParams }, appModel, Nav.pushUrl routerModel.navKey (pathToUrl matchedPath) )

        OnUrlRequest (Browser.External href) ->
            ( routerModel, appModel, Nav.load href )

        OnUrlChange url ->
            let
                matchedPath = matchRoute routerModel.config url
                pathParams = parsePathParams routerModel.config url
            in
            ( { routerModel | currentPath = matchedPath, pathParams = pathParams }, appModel, perform (Navigate matchedPath) )
        _ -> (routerModel, appModel, Cmd.none)

view : Model model msg -> model -> Html msg
view routerModel appModel =
    case findRouteConfig routerModel.config routerModel.currentPath of
        Just routeConfig -> routeConfig.view appModel
        Nothing -> Html.text "Route not found"

navigate : String -> Model model msg -> Cmd Msg
navigate targetPath model =
    Nav.pushUrl model.navKey (pathToUrl targetPath)

link : String -> Config model msg -> List (Html Msg) -> Html Msg
link path _ content =
    Html.a [ Html.Attributes.href (pathToUrl path), Html.Attributes.attribute "onclick" "event.preventDefault()" ] content

matchRoute : Config model msg -> Url -> String
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
