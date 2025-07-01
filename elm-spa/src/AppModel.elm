module AppModel exposing (Model, Msg(..), init, update)

import Page.Blocks as Blocks

type alias Model =
    { blocks : Blocks.Model
    }

type Msg
    = BlocksMsg Blocks.Msg

init : () -> ( Model, Cmd Msg )
init _ =
    let
        ( blocksModel, blocksCmd ) = Blocks.init ()
    in
    ( { blocks = blocksModel }
    , Cmd.map BlocksMsg blocksCmd
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BlocksMsg blocksMsg ->
            let
                ( updatedBlocksModel, blocksCmd ) = Blocks.update blocksMsg model.blocks
            in
            ( { model | blocks = updatedBlocksModel }, Cmd.map BlocksMsg blocksCmd )
