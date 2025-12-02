//// Text Adventure Main Loop (Gleam on the BEAM)
////
//// This module launches the game, sets up the initial `GameState`,
//// and runs the interactive loop that reads player input from stdin.
//// It relies on the `in` package for direct line-by-line input on the BEAM,
//// with no external runtimes required.
////
//// Player Command Summary:
//// • look — view the current room
//// • go <direction> — move to an adjacent room (north, south, east, west, up, down)
//// • take <item> — pick up an item in the room
//// • examine <item> — inspect an item for more detail
//// • use <item> — attempt to use an item in your inventory
//// • inventory — list items you are carrying
//// • help — show available commands
//// • quit — exit the game
////
//// Module Overview:
////   - parser.gleam converts raw text into `Command` values.
////   - game.gleam interprets commands and updates `GameState`.
////   - world.gleam defines the static world: rooms, exits, items.
////   - text_adventure.gleam (this file) manages input/output and
////     drives the main interactive loop.

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
