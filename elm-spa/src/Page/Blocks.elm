module Page.Blocks exposing (initModel, update, view, routeConfig, getBlocks)

import Html exposing (Html, div, text, ul, li, table, tr, td, th, thead, tbody, a)
import Http
import Json.Decode as Decode exposing (Decoder, field, string, int, bool, nullable)
import Json.Encode as Encode
import RouteConfig exposing (RouteConfig, Path(..))
import Shared exposing (Model(..), Msg(..), Block, BlocksMsg(..))
import Html.Attributes exposing (class, href)
import Router

type alias BlocksModel =
    { blocks : List Block
    , error : Maybe String
    }

initModel : BlocksModel
initModel =
    { blocks = [], error = Nothing }

update : BlocksMsg -> BlocksModel -> ( BlocksModel, Cmd BlocksMsg )
update msg model =
    case msg of
        GotBlocks result ->
            case result of
                Ok blocks ->
                    ( { model | blocks = blocks, error = Nothing }, Cmd.none )
                Err error ->
                    ( { model | error = Just (errorToString error), blocks = [] }, Cmd.none )

        GetBlocks ->
            ( model, getBlocks )

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

getBlocks : Cmd BlocksMsg
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

view : Model -> Html Msg
view (Model model) =
    div [ class "flex justify-center my-8" ]
        [ case model.blocks of
            Just blocksModel ->
                case blocksModel.error of
                    Just error ->
                        div [] [ text ("Error: " ++ error) ]
                    Nothing ->
                        if List.isEmpty blocksModel.blocks then
                            div [] [ text "Loading..." ]
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
                                    (List.map viewBlock blocksModel.blocks)
                                ]
            Nothing ->
                div [] [ text "Loading..." ]
        ]

viewBlock : Block -> Html Msg
viewBlock block =
    tr []
        [ td [ class "border border-gray-300 px-4 py-2" ] [ text (String.fromInt block.blockHeight) ]
        , td [ class "border border-gray-300 px-4 py-2" ]
            [ a [ href ("/blocks/" ++ block.stateHash), class "text-blue-500 hover:underline" ] [ text block.stateHash ] ]
        , td [ class "border border-gray-300 px-4 py-2" ] [ text (if block.canonical then "Yes" else "No") ]
        , td [ class "border border-gray-300 px-4 py-2" ] [ text (Maybe.withDefault "N/A" block.coinbaseReceiverUsername) ]
        , td [ class "border border-gray-300 px-4 py-2" ] [ text block.snarkFees ]
        ]

routeConfig : RouteConfig Model Msg
routeConfig =
    { path = Static "blocks"
    , view = view
    }
