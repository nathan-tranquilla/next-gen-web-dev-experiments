module Page.BlockSpotlight exposing (view)

import Html exposing (Html, div, text)


view : String -> Html msg
view statehash =
    div []
        [ text "Block Spotlight Page"
        , div [] [ text ("Statehash: " ++ statehash) ]
        ]
