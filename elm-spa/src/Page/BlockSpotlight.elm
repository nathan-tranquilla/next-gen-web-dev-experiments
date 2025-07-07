module Page.BlockSpotlight exposing (view)

import Html exposing (Html, div, text)

view : String -> Html msg
view stateHash=
    div []
        [ text "Block Spotlight Page"
        , div [] [ text ("Statehash: " ++ stateHash) ]
        ]

