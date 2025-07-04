module RouteConfig exposing (RouterConfig, RouteConfig, Path(..))

import Html exposing (Html)
import Url.Parser exposing (Parser)

type alias RouterConfig model msg =
    { routes : List (RouteConfig model msg)
    , defaultPath : String
    }

type alias RouteConfig model msg =
    { path : Path
    , view : model -> Html msg
    }

type Path
    = Static String
    | Dynamic (Parser (String -> String) String)
    | CatchAll
