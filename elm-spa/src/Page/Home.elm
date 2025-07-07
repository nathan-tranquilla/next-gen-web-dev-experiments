module Page.Home exposing (view)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)

view : Html msg
view =
    div []
        [ h1 [ class "flex justify-center my-8" ] [ text "Welcome to the MINA Blockchain Explorer" ]
        ]

