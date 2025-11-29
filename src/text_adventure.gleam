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
//// This module sets up a small demo world and runs a scripted
//// sequence of text commands using `run_script`, showing how:
////   - parser.gleam turns strings into `Command` values
////   - game.gleam updates `GameState` in response
////   - output is printed for each command.

import game.{
  type GameState, Exit, GameState, Item, North, Room, direction_to_string,
  update,
}
import gleam/io
import parser

/// Entry point for the text adventure demo
/// Uses run_script to simulate multiple commands in sequence
pub fn main() {
  // Example: convert a Direction to text (demonstration only)
  let direction = North
  let direction_string = direction_to_string(direction)
  // Define the secondary room in the world (destination)
  let clearing = Room("Clearing", "A sunny clearing with soft grass.", [], [])
  // Define the starting room (Forest) with an exit leading north to the Clearing
  let room =
    Room("Forest", "A quiet forest.", [Exit(North, "Clearing")], [
      Item("key"),
    ])
  // Initialize the game: the player begins in Forest with both rooms available
  let state = GameState("Forest", [room, clearing], [])
  // Execute a script of demo commands to simulate gameplay
  let _final_state =
    run_script(state, [
      "look",
      "take key",
      "go north",
      "look",
      "inventory",
    ])

  // Print demonstration output unrelated to the script
  io.println("Direction as text: " <> direction_string)
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
