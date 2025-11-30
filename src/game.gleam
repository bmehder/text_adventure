//// Game Engine Module
////
//// This module defines the core logic for the text adventure engine.
//// It includes:
////
//// • Core types:
////     - Direction: possible movement directions
////     - Command: actions parsed from player input
////     - Room: locations in the world with exits and items
////     - GameState: the full world + player location + inventory
////     - Exit: a directional connection to another room
////     - Item: a named object that can be picked up
////
//// • Public functions:
////     - direction_to_string: convert Direction to text
////     - find_room: locate a room by name
////     - update: apply a Command to a GameState and return the result
////
//// • Private helpers:
////     - Movement handling (find_exit, handle_move)
////     - Room description (handle_look)
////     - Item interaction (handle_take)
////     - Inventory listing (handle_inventory)
////
//// All updates are pure: `update` always returns a new GameState
//// along with a message describing the outcome.

// Core game engine module: types, helpers, and update logic
import gleam/list
import gleam/string

/// Cardinal directions a player can move in
pub type Direction {
  North
  East
  South
  West
}

/// An exit from a room: a direction and the destination room name
pub type Exit {
  Exit(direction: Direction, destination: String)
}

/// An item in the world, identified by its name
pub type Item {
  Item(name: String)
}

/// Possible commands parsed from player input
pub type Command {
  Look
  Move(Direction)
  Inventory
  Take(Item)
  Unknown(String)
  Quit
  Help
}

/// A room in the world with its name, description, exits, and items
pub type Room {
  Room(name: String, description: String, exits: List(Exit), items: List(Item))
}

/// Overall game state: where the player is, all rooms, and inventory
pub type GameState {
  GameState(current_room: String, rooms: List(Room), inventory: List(Item))
}

/// A message shown to the player after a command is processed
type Message =
  String

/// Dispatch a Command to the appropriate handler function
pub fn update(state: GameState, command: Command) -> #(GameState, Message) {
  case command {
    Look -> handle_look(state)
    Move(dir) -> handle_move(state, dir)
    Take(item) -> handle_take(state, item)
    Inventory -> handle_inventory(state)
    Help -> #(
      state,
      "Available commands:\nlook\ngo <direction>\ntake <item>\ninventory\nhelp\nquit",
    )
    Quit -> #(state, "Goodbye.")
    Unknown(text) -> #(state, "I don't understand " <> text)
  }
}

/// Convert a Direction into lowercase text
fn direction_to_string(dir: Direction) -> String {
  case dir {
    North -> "north"
    East -> "east"
    South -> "south"
    West -> "west"
  }
}

/// Look up a room by name within the room list
fn find_room(rooms: List(Room), name: String) -> Result(Room, Nil) {
  case rooms {
    [] -> Error(Nil)

    [Room(room_name, description, exits, items), ..rest] ->
      case room_name == name {
        True -> Ok(Room(room_name, description, exits, items))

        False -> find_room(rest, name)
      }
  }
}

/// Find the exit (direction + destination) that matches the given direction
fn find_exit(exits: List(Exit), dir: Direction) -> Result(Exit, Nil) {
  case exits {
    [] -> Error(Nil)

    [Exit(direction, destination), ..rest] ->
      case direction == dir {
        True -> Ok(Exit(direction, destination))

        False -> find_exit(rest, dir)
      }
  }
}

/// Handle the LOOK command: show the room's name, description, and items
fn handle_look(state: GameState) -> #(GameState, Message) {
  let GameState(current_room, rooms, _) = state

  case find_room(rooms, current_room) {
    Error(Nil) -> #(state, "You are nowhere.")

    Ok(room) -> {
      let Room(name, description, _, items) = room

      let item_text = case items {
        [] -> "There are no items here."
        _ -> {
          let names =
            list.map(items, fn(item) {
              let Item(name) = item
              "- " <> name
            })
          "You see here:\n" <> string.join(names, with: "\n")
        }
      }

      let message = name <> "\n" <> description <> "\n\n" <> item_text

      #(state, message)
    }
  }
}

/// Handle movement: change current room if an exit matches
fn handle_move(state: GameState, dir: Direction) -> #(GameState, Message) {
  let GameState(current_room, rooms, inventory) = state

  case find_room(rooms, current_room) {
    Error(Nil) -> #(state, "You are nowhere.")

    Ok(Room(_, _, exits, _)) ->
      case find_exit(exits, dir) {
        Error(Nil) -> #(state, "You can't go that way.")

        Ok(Exit(_, destination)) -> {
          let new_state = GameState(destination, rooms, inventory)
          #(new_state, "You go " <> direction_to_string(dir) <> ".")
        }
      }
  }
}

/// Handle taking an item: remove from room, add to inventory
fn handle_take(state: GameState, item: Item) -> #(GameState, Message) {
  let GameState(current_room, rooms, inventory) = state

  // Look up the room
  case find_room(rooms, current_room) {
    Error(Nil) -> #(state, "You are nowhere.")

    Ok(Room(name, description, exits, items)) -> {
      case list.contains(items, item) {
        False -> #(
          state,
          "There is no "
            <> case item {
            Item(n) -> n
          }
            <> " here.",
        )

        True -> {
          // Remove the item from the room
          let new_items = list.filter(items, fn(i) { i != item })

          // Rebuild the updated room
          let updated_room = Room(name, description, exits, new_items)

          // Replace it in the room list
          let new_rooms =
            list.map(rooms, fn(r) {
              case r {
                Room(n, _, _, _) if n == name -> updated_room
                _ -> r
              }
            })

          // Add to inventory
          let new_inventory = [item, ..inventory]

          let new_state = GameState(current_room, new_rooms, new_inventory)

          #(
            new_state,
            "You take the "
              <> case item {
              Item(n) -> n
            }
              <> ".",
          )
        }
      }
    }
  }
}

/// Print the player inventory as a comma‑separated list
fn handle_inventory(state: GameState) -> #(GameState, Message) {
  let GameState(_, _, inventory) = state

  case inventory {
    [] -> #(state, "You are carrying nothing.")

    items -> {
      let names =
        list.map(items, fn(item) {
          let Item(name) = item
          name
        })
      let list_text = string.join(names, with: ", ")

      #(state, "You are carrying: " <> list_text)
    }
  }
}
