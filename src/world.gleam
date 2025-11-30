//// world.gleam
//// Contains all room definitions for the text adventure world.

import game.{type Room, East, Exit, Item, North, Room, South, West}

pub const starting_room = "Kaer Morhen Gate"

pub fn initial_world() -> List(Room) {
  let room =
    Room(
      name: "Kaer Morhen Gate",
      description: "The old keep’s weathered entrance, battered by countless winters.",
      exits: [
        Exit(North, "Training Yard"),
        Exit(East, "Old Armory"),
        Exit(West, "Keep Courtyard"),
      ],
      items: [Item("witcher medallion")],
    )
  let clearing =
    Room(
      name: "Training Yard",
      description: "Weathered practice dummies and broken swords lie scattered across the packed earth.",
      exits: [Exit(South, "Kaer Morhen Gate"), Exit(East, "Old Armory")],
      items: [Item("broken training sword")],
    )
  let armory =
    Room(
      name: "Old Armory",
      description: "Dusty racks of weathered blades and dented shields line the cold stone walls.",
      exits: [Exit(West, "Training Yard")],
      items: [Item("rusty short sword")],
    )
  let courtyard =
    Room(
      name: "Keep Courtyard",
      description: "A broad stone courtyard, echoes of old training sessions lingering in the cold air.",
      exits: [Exit(East, "Kaer Morhen Gate")],
      items: [Item("weathered practice shield")],
    )
  [clearing, armory, room, courtyard]
}
