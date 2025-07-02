module Lap exposing (Model(..), Msg(..), view, update)

import Html exposing (Html, div, button, ul, li, text)
import Html.Events exposing (onClick)

type Model
    = Model
        { items : List String
        , laps : List Int
        }

type Msg
    = RecordLap

view : Model -> Html Msg
view (Model model) =
    div []
        [ button [ onClick RecordLap ]
            [ text "Record Lap" ]
        , ul []
            (List.indexedMap
                (\i count -> li [] [ text ("Lap " ++ String.fromInt (i + 1) ++ ": " ++ String.fromInt count ++ " seconds") ])
                model.laps
            )
        ]

update : Msg -> Model -> Model
update msg (Model model) =
    case msg of
        RecordLap ->
            -- Semantic error: Intends to record item count in laps, but clears items
            Model { model | items = [], laps = model.laps ++ [ List.length model.items ] }
