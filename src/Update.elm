module Update exposing (..)

import Set exposing (Set)
import Keyboard exposing (KeyCode)

import Model exposing (..)
import Model.Ui exposing (..)
import Model.Scene exposing (..)
import Subscription exposing (..)

import Debug exposing (log)
------------------------------------------------------------------------- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update action ({ui,scene} as model) =
  case action of
    ResizeWindow dimensions ->
      ({ model | ui = { ui | windowSize = dimensions } }, Cmd.none)

    Tick time ->
      let
          player' = stepPlayer ui scene.player
          scene' = { scene | t = time, player = player' }
      in
         if time > model.lastRender+40 then
           ({ model | scene = scene', lastRender = time }, Cmd.none)
         else
           (model, Cmd.none)

    KeyChange pressed keycode ->
      let
          pressedKeys' =  (if pressed then Set.insert else Set.remove) keycode ui.pressedKeys
          ui' = { ui | pressedKeys = pressedKeys' }
      in
          ({ model | ui = ui' }, Cmd.none)

    NoOp ->
      (model, Cmd.none)


stepPlayer : Ui -> Player -> Player
stepPlayer {pressedKeys} ({position,velocity} as player) =
  let
      directionX = if keyPressed 65 pressedKeys then
                     -1
                   else if keyPressed 68 pressedKeys then
                     1
                   else
                     0
      ax = directionX * 0.007
      vx = velocity.x + ax |> friction |> speedLimit
      position' = { position | x = position.x + vx }
      velocity' = { velocity | x = vx }
  in
      { player
      | position = position'
      , velocity = velocity' }


speedLimit : Float -> Float
speedLimit vx =
  let
      maxSpeed = 0.03
  in
      vx
      |> max -maxSpeed
      |> min maxSpeed


friction : Float -> Float
friction vx =
  vx * 0.88
