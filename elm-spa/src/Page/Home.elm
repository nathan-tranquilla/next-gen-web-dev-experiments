module Page.Home exposing (view, routeConfig)

import Html exposing (Html, div, h1, text)
import RouteConfig exposing (RouteConfig, Path(..))

view : Html msg
view =
    div []
        [ h1 [] [ text "Home Page" ]
        ]

routeConfig : RouteConfig model msg
routeConfig =
    { path = Static ""
    , view = \_ -> view
    }
