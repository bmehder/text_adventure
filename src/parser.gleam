//// Parser module: converts raw user text into Command values
//// Turns raw text input into `Command` values for the game engine.

import game
import gleam/list
import gleam/string

/// Entry point: clean input and dispatch to specific parsers
pub fn parse(input: String) -> game.Command {
  let cleaned =
    input
    |> string.trim
    |> string.lowercase

  case cleaned {
    "look" -> game.Look

    "inventory" -> game.Inventory

    _ -> parse_move(cleaned)
  }
}

/// Split text into non-empty words (handles multiple spaces)
fn words(text: String) -> List(String) {
  text
  |> string.split(" ")
  |> list.filter(fn(part) { part != "" })
}

/// Parse commands like "take key" into Take(item)
fn parse_take(input: String) -> game.Command {
  let cleaned = string.trim(input)
  let parts = words(cleaned)

  case parts {
    ["take", item] -> game.Take(game.Item(item))
    _ -> game.Look
  }
}

/// Parse movement commands like "go north" into Move(Direction)
fn parse_move(input: String) -> game.Command {
  let parts = words(input)

  case parts {
    ["go", "north"] -> game.Move(game.North)
    ["go", "south"] -> game.Move(game.South)
    ["go", "east"] -> game.Move(game.East)
    ["go", "west"] -> game.Move(game.West)
    _ -> parse_take(input)
  }
}
