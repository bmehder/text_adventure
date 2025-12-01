//// Parser: converts cleaned user text into `Command` values.
//// 
//// Supported commands:
////  - look
////  - inventory
////  - take <item>
////  - go <direction>
////  - help
////  - quit
////  - <anything else> → Unknown(command_text)
////
//// This module only handles text → Command parsing.
//// Game logic is in `game.gleam`.

import game
import gleam/list
import gleam/string

/// Clean input and convert it into a `Command` for the game to handle.
pub fn parse(input: String) -> game.Command {
  let cleaned_input =
    input
    |> string.trim
    |> string.lowercase

  let parts = words(cleaned_input)

  case parts {
    ["look"] -> game.Look
    ["inventory"] -> game.Inventory
    ["help"] -> game.Help
    ["quit"] -> game.Quit

    ["go", ..rest] -> parse_move(rest, cleaned_input)
    ["take", ..rest] -> parse_take(rest, cleaned_input)

    _ -> game.Unknown(cleaned_input)
  }
}

/// Split text into non-empty words, collapsing multiple spaces.
fn words(text: String) -> List(String) {
  text
  |> string.split(" ")
  |> list.filter(fn(part) { part != "" })
}

/// Parse a `take` command. Everything after "take" is treated as the
/// item name. If no item is provided, returns `Unknown`.
fn parse_take(rest: List(String), raw: String) -> game.Command {
  case rest {
    [] -> game.Unknown(raw)
    _ -> {
      let name = string.join(rest, with: " ")
      game.Take(game.Item(name))
    }
  }
}

/// Parse a `go` command. Expects a single direction ("north", "south",
/// "east", "west"). Anything else becomes `Unknown`.
fn parse_move(rest: List(String), raw: String) -> game.Command {
  case rest {
    ["north"] -> game.Move(game.North)
    ["south"] -> game.Move(game.South)
    ["east"] -> game.Move(game.East)
    ["west"] -> game.Move(game.West)
    _ -> game.Unknown(raw)
  }
}
