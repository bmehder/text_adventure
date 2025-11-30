//// Parser module: converts raw user text into Command values
//// Supported commands:
////   look
////   inventory
////   take <item>
////   go <direction>
////   help
////   quit
////   <anything else> → Unknown

import game
import gleam/list
import gleam/string

/// Entry point: clean input and dispatch to specific parsers
pub fn parse(input: String) -> game.Command {
  let cleaned_input =
    input
    |> string.trim
    |> string.lowercase

  let parts = words(cleaned_input)

  case parts {
    [] -> game.Unknown(cleaned_input)

    ["look"] -> game.Look
    ["inventory"] -> game.Inventory
    ["help"] -> game.Help
    ["quit"] -> game.Quit

    ["go", ..rest] -> parse_move(rest, cleaned_input)
    ["take", ..rest] -> parse_take(rest, cleaned_input)

    _ -> game.Unknown(cleaned_input)
  }
}

/// Split text into non-empty words (handles multiple spaces)
fn words(text: String) -> List(String) {
  text
  |> string.split(" ")
  |> list.filter(fn(part) { part != "" })
}

/// Parse a `take` command. Accepts one or more words after "take"
/// and treats them as an item name. If no item is provided,
/// returns `Unknown`.
fn parse_take(rest: List(String), raw: String) -> game.Command {
  case rest {
    [] -> game.Unknown(raw)
    _ -> {
      let name = string.join(rest, with: " ")
      game.Take(game.Item(name))
    }
  }
}

/// Parse a `go` command. Accepts a single direction after "go"
/// and converts it to a `Move` command. If the direction is not
/// recognized, returns `Unknown`.
fn parse_move(rest: List(String), raw: String) -> game.Command {
  case rest {
    ["north"] -> game.Move(game.North)
    ["south"] -> game.Move(game.South)
    ["east"] -> game.Move(game.East)
    ["west"] -> game.Move(game.West)
    _ -> game.Unknown(raw)
  }
}
