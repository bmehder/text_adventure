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

import game.{
  type GameState, East, Exit, GameState, Item, North, Quit, Room, South, West,
  update,
}
import gleam/io
import gleam/string
import input
import parser

fn demo_script() -> List(String) {
  [
    "look", "take witcher medallion", "go north", "look",
    "take broken training sword", "inventory",
  ]
}

fn read_one_line() -> String {
  input.read_line("> ")
}

/// Entry point for the text adventure demo
/// Uses run_script to simulate multiple commands in sequence
pub fn main() {
  // Define the secondary room in the world (destination)
  let clearing =
    Room(
      name: "Training Yard",
      description: "Weathered practice dummies and broken swords lie scattered across the packed earth.",
      exits: [Exit(South, "Kaer Morhen Gate")],
      items: [Item("broken training sword")],
    )
  let armory =
    Room(
      name: "Old Armory",
      description: "Dusty racks of weathered blades and dented shields line the cold stone walls.",
      exits: [Exit(West, "Kaer Morhen Gate")],
      items: [Item("rusty short sword")],
    )
  // Define the starting room (Forest) with an exit leading north to the Clearing
  let room =
    Room(
      name: "Kaer Morhen Gate",
      description: "The old keep’s weathered entrance, battered by countless winters.",
      exits: [Exit(North, "Training Yard"), Exit(East, "Old Armory")],
      items: [Item("witcher medallion")],
    )
  // Initialize the game: the player begins in Forest with both rooms available
  let state = GameState("Kaer Morhen Gate", [room, clearing, armory], [])
  // Execute a script of demo commands to simulate gameplay
  let _final_state = run_script(state, demo_script())

  // Start the actual interactive game loop
  game_loop(state)
}

/// Execute a list of text commands one by one, updating state each time
/// This acts as a simple non-interactive game loop
fn run_script(state: GameState, commands: List(String)) -> GameState {
  case commands {
    [] -> state

    [command_string, ..rest] -> {
      // Parse a command string into a Command value
      let command = parser.parse(command_string)
      let #(new_state, output) = update(state, command)
      // Echo the command being executed
      io.println("> " <> command_string)
      // Print the result of executing the command
      io.println(output)
      run_script(new_state, rest)
    }
  }
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
