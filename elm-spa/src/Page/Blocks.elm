module Page.Blocks exposing (Model, Msg, init, update, view, initModel)

import Html exposing (Html, div, text, ul, li)
import Http
import Json.Decode as Decode exposing (Decoder, field, string, int, bool, nullable)
import Json.Encode as Encode

-- MODEL

type alias Block =
    { canonical : Bool
    , blockHeight : Int
    , stateHash : String
    , coinbaseReceiverUsername : Maybe String
    , snarkFees : String
    }

type alias Model =
    { blocks : List Block
    , error : Maybe String
    }

initModel : Model
initModel =
    { blocks = [], error = Nothing }

init : () -> ( Model, Cmd Msg )
init _ =
    ( { blocks = [], error = Nothing }
    , getBlocks
    )

-- UPDATE

type Msg
    = GotBlocks (Result Http.Error (List Block))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotBlocks result ->
            case result of
                Ok blocks ->
                    ( { model | blocks = blocks, error = Nothing }, Cmd.none )
                Err error ->
                    ( { model | error = Just (errorToString error), blocks = [] }, Cmd.none )

errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadUrl url ->
            "Invalid URL: " ++ url
        Http.Timeout ->
            "Request timed out"
        Http.NetworkError ->
            "Network error"
        Http.BadStatus status ->
            "Bad status: " ++ String.fromInt status
        Http.BadBody body ->
            "Invalid response: " ++ body

-- HTTP REQUEST

getBlocks : Cmd Msg
getBlocks =
    Http.post
        { url = "https://api.minasearch.com/graphql"
        , body = Http.jsonBody (Encode.object [ ( "query", Encode.string """
            {
              blocks(limit: 10) {
                canonical
                blockHeight
                stateHash
                coinbaseReceiverUsername
                snarkFees
              }
            }
            """ ) ])
        , expect = Http.expectJson GotBlocks blocksDecoder
        }

-- JSON DECODER

blocksDecoder : Decoder (List Block)
blocksDecoder =
    Decode.field "data" (Decode.field "blocks" (Decode.list blockDecoder))

blockDecoder : Decoder Block
blockDecoder =
    Decode.map5 Block
        (field "canonical" bool)
        (field "blockHeight" int)
        (field "stateHash" string)
        (field "coinbaseReceiverUsername" (nullable string))
        (field "snarkFees" string)

-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ text "Blocks Page - Latest Blocks"
        , case model.error of
            Just error ->
                div [] [ text ("Error: " ++ error) ]
            Nothing ->
                if List.isEmpty model.blocks then
                    div [] [ text "Loading..." ]
                else
                    ul []
                        (List.map viewBlock model.blocks)
        ]

viewBlock : Block -> Html Msg
viewBlock block =
    li []
        [ text ("Height: " ++ String.fromInt block.blockHeight
               ++ ", StateHash: " ++ block.stateHash
               ++ ", Canonical: " ++ (if block.canonical then "Yes" else "No")
               ++ ", Coinbase: " ++ (Maybe.withDefault "N/A" block.coinbaseReceiverUsername)
               ++ ", Fees: " ++ block.snarkFees)
        ]
