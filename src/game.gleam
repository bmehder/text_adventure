//// Game Engine Module
////
//// This module defines the core logic for the text adventure engine.
//// It includes:
////
//// • Core types:
////  - Direction: possible movement directions
////  - RoomName: wrapper for room identifiers
////  - Description: wrapper for room text
////  - Command: actions parsed from player input
////  - Room: locations in the world with exits and items
////  - GameState: the full world + player location + inventory
////  - Exit: a directional connection to another room
////  - Item: a named object that can be picked up
////
//// • Public functions:
////  - update: apply a Command to a GameState and return the result
////
//// • Private helpers:
////  - find_room: locate a room by name
////  - Movement handling (find_exit, handle_move)
////  - Room description (handle_look)
////  - Item interaction (handle_take)
////  - Inventory listing (handle_inventory)
////  - direction_to_string: convert Direction to text
////
//// All updates are pure: `update` always returns a new GameState
//// along with a textual message describing the outcome.

import gleam/list
import gleam/string

/// A wrapper for room identifiers
pub type RoomName {
  RoomName(String)
}

/// A wrapper for room text
pub type Description {
  Description(String)
}

/// Cardinal directions a player can move in
pub type Direction {
  North
  East
  South
  West
}

/// A connection from one room to another in a given direction
pub type Exit {
  Exit(direction: Direction, destination: RoomName)
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

/// A room in the world with its name (a Destination), description (a Description), exits, and items
pub type Room {
  Room(
    name: RoomName,
    description: Description,
    exits: List(Exit),
    items: List(Item),
  )
}

/// Overall game state: where the player is (a Destination), all rooms, and inventory
pub type GameState {
  GameState(current_room: RoomName, rooms: List(Room), inventory: List(Item))
}

/// A message shown to the player after a command is processed
pub type Message {
  Message(String)
}

/// Dispatch a Command to the appropriate handler function
pub fn update(state: GameState, command: Command) -> #(GameState, Message) {
  case command {
    Look -> handle_look(state)
    Move(direction) -> handle_move(state, direction)
    Take(item) -> handle_take(state, item)
    Inventory -> handle_inventory(state)
    Help -> #(
      state,
      Message(
        "Available commands:\nlook\ngo <direction>\ntake <item>\ninventory\nhelp\nquit",
      ),
    )
    Quit -> #(state, Message("Goodbye."))
    Unknown(text) -> #(state, Message("I don't understand " <> text))
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

    [Room(room_dest, description, exits, items), ..rest] -> {
      let RoomName(room_name) = room_dest

      case room_name == name {
        True -> Ok(Room(room_dest, description, exits, items))
        False -> find_room(rest, name)
      }
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

/// Handle the LOOK command: produce a message showing the room's name,
/// description, and any items present
fn handle_look(state: GameState) -> #(GameState, Message) {
  let GameState(current_room, rooms, _) = state
  let RoomName(room_name) = current_room

  case find_room(rooms, room_name) {
    Error(Nil) -> #(state, Message("You are nowhere."))

    Ok(room) -> {
      let Room(name, description, _, items) = room
      let RoomName(room_name) = name

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

      let Description(description) = description
      let message = room_name <> "\n" <> description <> "\n\n" <> item_text

      #(state, Message(message))
    }
  }
}

/// Handle movement: change current room if an exit matches
fn handle_move(state: GameState, dir: Direction) -> #(GameState, Message) {
  let GameState(current_room, rooms, inventory) = state
  let RoomName(room_name) = current_room

  case find_room(rooms, room_name) {
    Error(Nil) -> #(state, Message("You are nowhere."))

    Ok(Room(_, _, exits, _)) ->
      case find_exit(exits, dir) {
        Error(Nil) -> #(state, Message("You can't go that way."))

        Ok(Exit(_, destination)) -> {
          let new_state = GameState(destination, rooms, inventory)
          #(new_state, Message("You go " <> direction_to_string(dir) <> "."))
        }
      }
  }
}

/// Handle taking an item: remove from room, add to inventory
fn handle_take(state: GameState, item: Item) -> #(GameState, Message) {
  let GameState(current_room, rooms, inventory) = state
  let RoomName(room_name) = current_room

  // Look up the room
  case find_room(rooms, room_name) {
    Error(Nil) -> #(state, Message("You are nowhere."))

    Ok(Room(name, description, exits, items)) -> {
      case list.contains(items, item) {
        False -> #(
          state,
          Message(
            "There is no "
            <> case item {
              Item(n) -> n
            }
            <> " here.",
          ),
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
            Message(
              "You take the "
              <> case item {
                Item(n) -> n
              }
              <> ".",
            ),
          )
        }
      }
    }
  }
}

/// Format the player inventory as a comma‑separated list in a message
fn handle_inventory(state: GameState) -> #(GameState, Message) {
  let GameState(_, _, inventory) = state

  case inventory {
    [] -> #(state, Message("You are carrying nothing."))

    items -> {
      let names =
        list.map(items, fn(item) {
          let Item(name) = item
          name
        })
      let list_text = string.join(names, with: ", ")

      #(state, Message("You are carrying: " <> list_text))
    }
  }
}
