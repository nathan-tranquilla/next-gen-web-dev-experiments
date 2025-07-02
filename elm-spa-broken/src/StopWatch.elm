module StopWatch exposing (Model(..), Msg(..), view, update)

import Html exposing (Html, div, ul, li, text)
import Time

type Model
    = Model
        { items : List String
        , laps : List Int
        }

type Msg
    = Tick

view : Model -> Html Msg
view (Model model) =
    div []
        [ ul []
            (List.map (\item -> li [] [ text item ]) model.items)
        ]

update : Msg -> Model -> Model
update msg (Model model) =
    case msg of
        Tick ->
            Model { model | items = model.items ++ [ "Second " ++ String.fromInt (List.length model.items + 1) ] }
