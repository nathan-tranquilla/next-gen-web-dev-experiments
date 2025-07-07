module Page.Blocks exposing (initModel, update, view, getBlocks, errorToString, Msg(..), Model)

import Html exposing (Html, div, text, table, tr, td, th, thead, tbody, a)
import Http
import Json.Decode as Decode exposing (Decoder, field, string, int, bool, nullable)
import Json.Encode as Encode
import Html.Attributes exposing (class, href)

type alias Model = { blocks : Maybe (List Block)
    , error : Maybe String }

type Msg = 
    GotBlocks (Result Http.Error (List Block))
    | GetBlocks
type alias Block =
    { canonical : Bool
    , blockHeight : Int
    , stateHash : String
    , coinbaseReceiverUsername : Maybe String
    , snarkFees : String
    }


initModel : Model
initModel = 
    { blocks = Nothing, error = Nothing }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotBlocks result ->
            case result of
                
                Ok blocks ->
                    ( { blocks = Just blocks, error = Nothing }, Cmd.none )
                Err error ->
                    ( { error = Just (errorToString error), blocks = Nothing }, Cmd.none )

        GetBlocks ->
            ( { blocks = Nothing, error = Nothing } , getBlocks )

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

view : Model -> Html msg
view model =
    div [ class "flex justify-center my-8" ]
        [ case model.blocks of
            Nothing ->
                div [] [ text "Loading..." ]

            Just blocks ->
                if List.isEmpty blocks then
                    div [] [ text "No blocks available." ]
                else
                    table [ class "table-auto border-collapse border border-gray-300 w-full" ]
                        [ thead []
                            [ tr []
                                [ th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "Height" ]
                                , th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "StateHash" ]
                                , th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "Canonical" ]
                                , th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "Coinbase" ]
                                , th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "Fees" ]
                                ]
                            ]
                        , tbody []
                            (List.map viewBlock blocks)
                        ]
        , case model.error of
            Just error ->
                div [ class "text-red-500 mt-4" ] [ text ("Error: " ++ error) ]
            Nothing ->
                text ""
        ]

viewBlock : Block -> Html msg
viewBlock block =
    tr []
        [ td [ class "border border-gray-300 px-4 py-2" ] [ text (String.fromInt block.blockHeight) ]
        , td [ class "border border-gray-300 px-4 py-2" ]
            [ a [ href ("/blocks/" ++ block.stateHash), class "text-blue-500 hover:underline" ] [ text block.stateHash ] ]
        , td [ class "border border-gray-300 px-4 py-2" ] [ text (if block.canonical then "Yes" else "No") ]
        , td [ class "border border-gray-300 px-4 py-2" ] [ text (Maybe.withDefault "N/A" block.coinbaseReceiverUsername) ]
        , td [ class "border border-gray-300 px-4 py-2" ] [ text block.snarkFees ]
        ]

