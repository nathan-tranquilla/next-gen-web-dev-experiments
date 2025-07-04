module Page.Home exposing (view, routeConfig)

import Html exposing (Html, div, h1, text)
import RouteConfig exposing (RouteConfig, Path(..))
import Html.Attributes exposing (class)

view : Html msg
view =
    div []
        [ h1 [ class "flex justify-center my-8" ] [ text "Welcome to the MINA Blockchain Explorer" ]
        ]

routeConfig : RouteConfig model msg
routeConfig =
    { path = Static ""
    , view = \_ -> view
    }
