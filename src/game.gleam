//// Game Engine
////
//// Core game logic:
////  - Types representing rooms, items, directions, commands, and game state
////  - `update` – applies a `Command` to the `GameState`
////  - Pure helper functions for movement, room lookup, item handling, and text output
////
//// All updates are pure: every command returns a new `GameState`
//// together with a `Message` describing the result.

import gleam/list
import gleam/string

/// Identifier for a room
pub type RoomName {
  RoomName(String)
}

/// Text describing a room
pub type Description {
  Description(String)
}

/// Possible movement directions
pub type Direction {
  North
  East
  South
  West
  Up
  Down
}

/// A directional link to another room
pub type Exit {
  Exit(direction: Direction, destination: RoomName)
}

/// An item in the world, identified by its name
pub type Item {
  Item(name: String)
}

/// Actions the player can perform
pub type Command {
  Look
  Move(Direction)
  Inventory
  Examine(String)
  Use(String)
  Take(Item)
  Unknown(String)
  Quit
  Help
}

/// A room: its name, description, exits, and items
pub type Room {
  Room(
    name: RoomName,
    description: Description,
    exits: List(Exit),
    items: List(Item),
  )
}

/// Complete game state: current room, world rooms, and player inventory
pub type GameState {
  GameState(current_room: RoomName, rooms: List(Room), inventory: List(Item))
}

/// Text returned after processing a command
pub type Message {
  Message(String)
}

/// Apply a command to the current state and return the updated state and a message
pub fn update(state: GameState, command: Command) -> #(GameState, Message) {
  case command {
    Look -> handle_look(state)
    Move(direction) -> handle_move(state, direction)
    Inventory -> handle_inventory(state)
    Examine(name) -> handle_examine(state, name)
    Use(name) -> handle_use(state, name)
    Take(item) -> handle_take(state, item)
    Help -> #(
      state,
      Message(
        "Available commands:\nlook\ngo <direction> (north, south, east, west, up, down)\ntake <item>\nexamine <item>\nuse <item>\ninventory\nhelp\nquit",
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
    Up -> "up"
    Down -> "down"
  }
}

/// Look up a room by its name
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

/// Look up an exit matching the given direction
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

/// Produce a description of the current room
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

/// Attempt to move the player in the given direction
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

/// Attempt to pick up an item from the current room
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

/// Produce a message listing the inventory contents
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

/// Look up a descriptive lore text for an item name
fn describe_item(name: String) -> String {
  case string.lowercase(name) {
    "witcher medallion" ->
      "A wolf-school medallion, its silver worn smooth by years of contracts.\nWhen you hold it still, a faint vibration hums through the metal — magic nearby."

    "broken training sword" ->
      "A battered practice blade, its edge notched beyond repair.\nCountless apprentices must have swung it before it finally gave out."

    "rusty short sword" ->
      "A once-serviceable short sword, now coated in a reddish bloom of rust.\nIt might still cut in a pinch… but you wouldn’t bet your life on it."

    "weathered practice shield" ->
      "A round training shield, scarred and cracked from years of drills.\nSomeone painted a faded wolf on its face long ago."

    "tempered steel ingot" ->
      "A heavy ingot of properly tempered steel, still warm to the touch.\nPerfect for reforging a blade — if you know what you’re doing."

    "ancient bestiary" ->
      "A brittle leather-bound tome filled with sketches and notes on monsters.\nSeveral pages crumble slightly as you turn them, yet the knowledge holds true."

    "eagle feather" ->
      "A pristine feather carried on a cold mountain wind.\nIts barbs shimmer faintly, as if touched by something more than nature."

    _ -> "You see nothing special about it."
  }
}

/// Attempt to examine an item either in the room or in inventory
fn handle_examine(state: GameState, name: String) -> #(GameState, Message) {
  let GameState(current_room, rooms, inventory) = state
  let RoomName(room_name) = current_room

  // Find the room
  case find_room(rooms, room_name) {
    Error(Nil) -> #(state, Message("You are nowhere."))

    Ok(Room(_, _, _, room_items)) -> {
      let needle = string.lowercase(name)

      let item_in_room =
        list.find(room_items, fn(item) {
          let Item(n) = item
          string.lowercase(n) == needle
        })

      let item_in_inventory =
        list.find(inventory, fn(item) {
          let Item(n) = item
          string.lowercase(n) == needle
        })

      case item_in_room {
        Ok(Item(_)) -> #(state, Message(describe_item(name)))

        Error(Nil) -> {
          case item_in_inventory {
            Ok(Item(_)) -> #(state, Message(describe_item(name)))
            Error(Nil) -> #(state, Message("You don't see that here."))
          }
        }
      }
    }
  }
}

/// Attempt to use an item. Now checks inventory before applying effect.
fn handle_use(state: GameState, name: String) -> #(GameState, Message) {
  let GameState(_, _, inventory) = state
  let needle = string.lowercase(name)

  // Check if the item is in the inventory
  let item_in_inventory =
    list.find(inventory, fn(item) {
      let Item(n) = item
      string.lowercase(n) == needle
    })

  case item_in_inventory {
    Error(Nil) -> #(state, Message("You must pick it up first."))

    Ok(Item(_)) ->
      case needle {
        "witcher medallion" -> #(
          state,
          Message(
            "You hold the wolf medallion still.\nA faint vibration hums through the metal — something magical stirs nearby.",
          ),
        )

        _ -> #(state, Message("You can't use that right now."))
      }
  }
}
