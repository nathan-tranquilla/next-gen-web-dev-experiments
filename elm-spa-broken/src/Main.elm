module Main exposing (main, Model(..), Msg(..))

import Browser
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (style)
import StopWatch
import Lap
import Time

type Model
    = Model
        { items : List String
        , laps : List Int
        }

type Msg
    = StopWatchMsg StopWatch.Msg
    | LapMsg Lap.Msg

main : Program () Model Msg
main =
    Browser.element
        { init = \() -> (init, Cmd.none)
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

init : Model
init =
    Model { items = [], laps = [] }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model model) =
    case msg of
        StopWatchMsg stopWatchMsg ->
            let
                (StopWatch.Model newStopWatchModel) = StopWatch.update stopWatchMsg (StopWatch.Model model)
            in
            ( Model newStopWatchModel, Cmd.none )

        LapMsg lapMsg ->
            let
                (Lap.Model newLapModel) = Lap.update lapMsg (Lap.Model model)
            in
            ( Model newLapModel, Cmd.none )

view : Model -> Html Msg
view (Model model) =
    div [ style "display" "flex", style "gap" "20px", style "padding" "20px" ]
        [ div [ style "flex" "1" ]
            [ h1 [] [ text "StopWatch" ]
            , Html.map StopWatchMsg (StopWatch.view (StopWatch.Model model))
            ]
        , div [ style "flex" "1" ]
            [ h1 [] [ text "Lap" ]
            , Html.map LapMsg (Lap.view (Lap.Model model))
            ]
        ]

subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 (\_ -> StopWatchMsg StopWatch.Tick)
