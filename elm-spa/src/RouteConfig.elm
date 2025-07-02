module RouteConfig exposing (Config, RouteConfig, Path(..), string)

import Html exposing (Html)
import Url.Parser as Parser exposing (Parser)

type alias Config model msg =
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

string : (String -> String) -> Path
string constructor =
    Dynamic (Parser.map constructor Parser.string)
