//// Text Adventure Engine Demo
////
//// Basic Player Commands (as typed input):
////
//// • "look"
////     View the current room's name and description.
////
//// • "go <direction>"
////     Move to an adjacent room in the given direction.
////     Valid directions are: north, south, east, west.
////     Internally this is parsed into a `Move(Direction)` command.
////
//// • "take <item>"
////     Pick up an item from the current room
////     and add it to your inventory.
////
//// • "inventory"
////     List all items the player is currently carrying.
//// 
//// • "help"
////    Display a list of available commands.
////
//// • "quit"
////     Exit the game loop and end the program.
////
//// This module sets up a small demo world and runs a scripted
//// sequence of text commands using `run_script`, showing how:
////   - parser.gleam turns strings into `Command` values
////   - game.gleam updates `GameState` in response
////   - output is printed for each command.

import game.{type GameState, GameState, Quit, update}
import gleam/io
import gleam/string
import input
import parser
import world

/// Entry point for the text adventure demo
pub fn main() {
  // Initialize the game.
  let state =
    GameState(
      current_room: world.starting_room,
      rooms: world.initial_world(),
      inventory: [],
    )
  // Start the actual interactive game loop
  game_loop(state)
}

fn game_loop(state: GameState) -> GameState {
  let line = string.trim(read_one_line())
  let command = parser.parse(line)
  let #(new_state, output) = update(state, command)

  io.println(output)

  case command {
    Quit -> new_state
    _ -> game_loop(new_state)
  }
}

fn read_one_line() -> String {
  input.read_line("> ")
}
