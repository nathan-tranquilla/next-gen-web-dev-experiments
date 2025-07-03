module Page.BlockSpotlight exposing (view, routeConfig)

import Html exposing (Html, div, text)
import RouteConfig exposing (RouteConfig, Path(..))
import Url.Parser as Parser exposing ((</>))
import Shared exposing (Model(..), Msg)

view : Model -> Html Msg
view (Model model) =
    div []
        [ text "Block Spotlight Page"
        , div [] [ text ("Statehash: " ++ (List.head model.router.pathParams |> Maybe.withDefault "unknown")) ]
        ]

routeConfig : RouteConfig Model Msg
routeConfig =
    { path = Dynamic (Parser.s "blocks" </> Parser.string)
    , view = view
    }
