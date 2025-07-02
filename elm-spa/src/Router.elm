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
                matchedPath = matchRoute model.config url
            in
            ( { model | currentPath = matchedPath }, externalModel, Nav.pushUrl model.navKey (pathToUrl matchedPath) )

        OnUrlRequest (Browser.External href) ->
            ( model, externalModel, Nav.load href )

        OnUrlChange url ->
            let
                matchedPath = matchRoute model.config url
            in
            ( { model | currentPath = matchedPath }, externalModel, Cmd.none )

        Navigate targetPath ->
            ( { model | currentPath = targetPath }, externalModel, Nav.pushUrl model.navKey (pathToUrl targetPath) )

view : Model model msg -> model -> Html msg
view model externalModel =
    case findRouteConfig model.config model.currentPath of
        Just routeConfig -> routeConfig.view externalModel
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
