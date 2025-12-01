//// Text Adventure (Gleam on the BEAM)
////
//// This game reads directly from standard input using the `in` package,
//// running entirely on the BEAM with no external runtime required.
////
//// Available Player Commands:
//// • "look"
////     View the current room's name and description.
////
//// • "go <direction>"
////     Move to an adjacent room. Valid directions: north, south, east, west.
////     Parsed into a `Move(Direction)` command.
////
//// • "take <item>"
////     Pick up an item from the current room and add it to your inventory.
////
//// • "inventory"
////     Show all items you're currently carrying.
////
//// • "help"
////     Display available commands and short explanations.
////
//// • "quit"
////     Exit the game loop and end the program cleanly.
////
//// How the modules work together:
////   - parser.gleam converts raw text input into `Command` values.
////   - game.gleam updates the `GameState` based on those commands.
////   - world.gleam defines the rooms, items, and exits.
////   - This file sets up the initial state and runs the interactive loop using
////     direct stdin input via the `in` package.

import game.{type GameState, GameState, Message, Quit, RoomName, update}
import gleam/io
import gleam/string
import in
import parser
import world

/// Entry point for the interactive text adventure
pub fn main() -> GameState {
  // Initialize the world and starting game state.
  let state =
    GameState(
      current_room: RoomName(world.starting_room),
      rooms: world.initial_world(),
      inventory: [],
    )
  // Start the actual interactive game loop
  game_loop(state)
}

fn game_loop(state: GameState) -> GameState {
  io.print("> ")
  let assert Ok(line) = in.read_line()
  let line = string.trim(line)
  let command = parser.parse(line)
  let #(new_state, output) = update(state, command)

  let Message(output) = output
  io.println(output)

  case command {
    Quit -> new_state
    _ -> game_loop(new_state)
  }
}
