module Game where

import Data.Maybe
import Data.Array
import Control.Alt
import Control.Monad
import Control.Monad.Reader.Class

import Types
import LevelMap
import Utils

handleInput :: Input -> GameUpdateM Unit
handleInput (Input i) =
  whenJust i $ \newDirection -> do
    game <- askGame
    case game.objects !! 0 of
      Just (GOPlayer p) ->
        tell $ ChangedIntendedDirection (Just newDirection)
      _ -> return unit

doLogic :: GameUpdateM Unit
doLogic = do
  game <- askGame
  case game.objects !! 0 of
    Just (GOPlayer p) ->
      do updateDirection p
         movePlayer p
    _ -> return unit

updateDirection :: Player -> GameUpdateM Unit
updateDirection p =
  whenJust p.intendedDirection $ tryChangeDirection p

movePlayer :: Player -> GameUpdateM Unit
movePlayer p =
  whenJust p.direction $ \dir ->
    tell $ ChangedPosition (moveInDirection dir p.position)

tryChangeDirection :: Player -> Direction -> GameUpdateM Unit
tryChangeDirection p d = do
  ok <- canMoveInDirection p d
  when ok $ do
    tell $ ChangedDirection (Just d)
    tell $ ChangedIntendedDirection Nothing

canMoveInDirection :: Player -> Direction -> GameUpdateM Boolean
canMoveInDirection p d =
  let newPosition = moveInDirection d p.position
      canMove game = isFree game.map newPosition
  in  canMove <$> askGame

moveInDirection :: Direction -> Position -> Position
moveInDirection d p = add p (dirToPos d)

isFree :: LevelMap -> Position -> Boolean
isFree levelmap pos =
  let block = getBlockAt pos levelmap
  in  maybe false isWall block

isWall :: Block -> Boolean
isWall Wall = true
isWall _ = false