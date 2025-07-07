module Page.BlockSpotlight exposing (view, Msg(..), Model, getBlocks, update, initModel)

import Html exposing (Html, div, text, table, tr, td, th, thead, tbody)
import Http
import Json.Decode as Decode exposing (Decoder, field, string, int, bool, nullable)
import Json.Encode as Encode
import Html.Attributes exposing (class)

type alias Model = { block : Maybe Block
    , error : Maybe String }

type Msg = 
    GotBlocks (Result Http.Error (List Block))
    | GetBlocks String

type alias Block =
    { canonical : Bool
    , blockHeight : Int
    , stateHash : String
    , coinbaseReceiverUsername : Maybe String
    , snarkFees : String
    }

initModel : Model
initModel = 
    { block = Nothing, error = Nothing }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotBlocks result ->
            case result of
                
                Ok blocks ->
                     case List.head blocks of
                        Just block ->
                            ( { block = Just block, error = Nothing }, Cmd.none )
                        Nothing ->
                            ( { block = Nothing, error = Just "No block found." }, Cmd.none )
                Err error ->
                    ( { error = Just (errorToString error), block = Nothing }, Cmd.none )

        GetBlocks stateHash ->
            ( { block = Nothing, error = Nothing } , getBlocks stateHash)

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


getBlocks : String -> Cmd Msg
getBlocks stateHash =
    Http.post
        { url = "https://api.minasearch.com/graphql"
        , body = Http.jsonBody (Encode.object [ ( "query", Encode.string (
            "{ blocks(limit: 1, query: { stateHash: \"" ++ stateHash ++ "\" }) { canonical blockHeight stateHash coinbaseReceiverUsername snarkFees } }"
        )) ])
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
    div [ class "block-spotlight-page" ]
        [ text "Block Spotlight Page"
        , case model.block of
            Nothing ->
                div [] [ text "Loading block data..." ]

            Just block ->
                table [ class "table-auto border-collapse border border-gray-300 w-full" ]
                    [ tbody []
                        [ tr []
                            [ th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "Canonical" ]
                            , td [ class "border border-gray-300 px-4 py-2" ] [ text (if block.canonical then "Yes" else "No") ]
                            ]
                        , tr []
                            [ th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "Block Height" ]
                            , td [ class "border border-gray-300 px-4 py-2" ] [ text (String.fromInt block.blockHeight) ]
                            ]
                        , tr []
                            [ th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "State Hash" ]
                            , td [ class "border border-gray-300 px-4 py-2" ] [ text block.stateHash ]
                            ]
                        , tr []
                            [ th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "Coinbase Receiver Username" ]
                            , td [ class "border border-gray-300 px-4 py-2" ] [ text (Maybe.withDefault "N/A" block.coinbaseReceiverUsername) ]
                            ]
                        , tr []
                            [ th [ class "border border-gray-300 px-4 py-2 text-left" ] [ text "Snark Fees" ]
                            , td [ class "border border-gray-300 px-4 py-2" ] [ text block.snarkFees ]
                            ]
                        ]
                    ]
        ]

