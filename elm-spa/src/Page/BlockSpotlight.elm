module Page.BlockSpotlight exposing (view)

import Html exposing (Html, div, text)
import Http
import Json.Decode as Decode exposing (Decoder, field, string, int, bool, nullable)
import Json.Encode as Encode


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
            "{ blocks(limit: 1, stateHash: \"" ++ stateHash ++ "\") { canonical blockHeight stateHash coinbaseReceiverUsername snarkFees } }"
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

view : String -> Html msg
view stateHash=
    div []
        [ text "Block Spotlight Page"
        , div [] [ text ("Statehash: " ++ stateHash) ]
        ]

