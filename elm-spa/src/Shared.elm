module Shared exposing (Model(..), Msg(..), Block, BlocksMsg(..))

import Router
import Http

type alias Block =
    { canonical : Bool
    , blockHeight : Int
    , stateHash : String
    , coinbaseReceiverUsername : Maybe String
    , snarkFees : String
    }

type Model
    = Model
        { router : Router.Model Model Msg
        , blocks : Maybe { blocks : List Block, error : Maybe String }
        }

type Msg
    = RouterMsg Router.Msg
    | BlocksMsg BlocksMsg

type BlocksMsg
    = GotBlocks (Result Http.Error (List Block))
    | GetBlocks
