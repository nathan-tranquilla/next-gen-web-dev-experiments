module Router exposing
    ( define
    , Model, Msg(..), init, update, view, navigate, link
    , matchRoute
    )

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, (</>))
import String
import RouteConfig exposing (Config, RouteConfig, Path(..))
import Debug
import Cmd.Extra exposing (perform)

type alias Model model msg =
    { currentPath : String
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
                Dynamic _ -> False
                CatchAll -> True
        )
        config.routes
        |> List.head

pathToUrl : String -> String
pathToUrl path =
    "/" ++ path

define : String -> List (RouteConfig model msg) -> Config model msg
define defaultPath routeConfigs =
    { routes = routeConfigs
    , defaultPath = defaultPath
    }

init : Config model msg -> Url -> Nav.Key -> ( Model model msg, Cmd Msg )
init config url key =
    let
        matchedPath = matchRoute config url
    in
    ( { currentPath = matchedPath, navKey = key, config = config }, Cmd.none )

update : Msg -> Model model msg -> model -> ( Model model msg, model, Cmd Msg )
update msg model externalModel =
    case msg of
        OnUrlRequest (Browser.Internal url) ->
            let
                _ = Debug.log "Router.update: case path" "OnUrlRequest Internal"
                _ = Debug.log "Router.update: url" (Url.toString url)
                matchedPath = matchRoute model.config url
                _ = Debug.log "Router.update: matchedPath" matchedPath
            in
            ( { model | currentPath = matchedPath }, externalModel, Nav.pushUrl model.navKey (pathToUrl matchedPath) )

        OnUrlRequest (Browser.External href) ->
            let
                _ = Debug.log "Router.update: case path" "OnUrlRequest External"
                _ = Debug.log "Router.update: href" href
            in
            ( model, externalModel, Nav.load href )

        OnUrlChange url ->
            let
                _ = Debug.log "Router.update: case path" "OnUrlChange"
                _ = Debug.log "Router.update: url" (Url.toString url)
                matchedPath = matchRoute model.config url
                _ = Debug.log "Router.update: matchedPath" matchedPath
            in
            ( { model | currentPath = matchedPath }, externalModel, perform (Navigate matchedPath) )

        _ -> (model, externalModel, Cmd.none)

view : Model model msg -> model -> Html msg
view model externalModel =
    case findRouteConfig model.config model.currentPath of
        Just routeConfig -> routeConfig.view externalModel
        Nothing -> Html.text "Route not found"

navigate : String -> Model model msg -> Cmd Msg
navigate targetPath model =
    Nav.pushUrl model.navKey (pathToUrl targetPath)

link : String -> Config model msg -> List (Html Msg) -> Html Msg
link path config content =
    Html.a [ Html.Attributes.href (pathToUrl path), Html.Attributes.attribute "onclick" "event.preventDefault()" ] content

matchRoute : Config model msg -> Url -> String
matchRoute config url =
    let
        normalizedPath = stripTrailingSlash (String.dropLeft 1 url.path)
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
                                dynamicParser
                            CatchAll ->
                                Parser.map normalizedPath Parser.top
                    )
                    config.routes
                )
        parsedPath = Parser.parse parser { url | path = normalizedPath }
    in
    parsedPath
        |> Maybe.withDefault config.defaultPath

stripTrailingSlash : String -> String
stripTrailingSlash str =
    if String.endsWith "/" str then
        String.dropRight 1 str
    else
        str
