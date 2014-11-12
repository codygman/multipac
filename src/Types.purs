module Types where

import Data.Maybe
import Data.Tuple
import Data.Array
import Control.Monad.Free
import Control.Monad.Reader.Trans
import Control.Monad.Reader.Class
import Control.Monad.State
--import Control.Monad.Trans
import Control.Monad.State.Class

import Utils

-- newtype wrapper is just so that the ReaderT instance works
type Game = {map :: LevelMap, objects :: [GameObject]}
newtype WrappedGame = WrappedGame Game

unwrapGame :: WrappedGame -> Game
unwrapGame (WrappedGame g) = g

type LevelMap = {blocks :: [[Block]]}
data Block = Wall | Empty

type Position = {x :: Number, y :: Number}
data GameObject = GOPlayer Player | GOItem Item

type Player
  = { position :: Position
    , direction :: Maybe Direction
    , intendedDirection :: Maybe Direction
    }

type Item
  = { position :: Position
    , itemType :: ItemType
    }

data Direction = Up | Down | Left | Right
data ItemType = LittleDot | BigDot | Cherry

dirToPos :: Direction -> Position
dirToPos Up    = {x:  0, y: -1}
dirToPos Left  = {x: -1, y:  0}
dirToPos Right = {x:  1, y:  0}
dirToPos Down  = {x:  0, y:  1}

add :: Position -> Position -> Position
add p q = {x: p.x + q.x, y: p.y + q.y}

data Input = Input (Maybe Direction)

data GameUpdate
  = ChangedDirection (Maybe Direction)
  | ChangedIntendedDirection (Maybe Direction)
  | ChangedPosition Position

type GameUpdateM a = ReaderT WrappedGame (State [GameUpdate]) a

tell :: GameUpdate -> GameUpdateM Unit
tell gu = modify (unshift gu)

askGame :: GameUpdateM Game
askGame = reader unwrapGame

-- runGameUpdateM :: forall a. Game -> GameUpdateM a -> Tuple [GameUpdate] a
-- runGameUpdateM game action =
--   runState (runReaderT game action) []