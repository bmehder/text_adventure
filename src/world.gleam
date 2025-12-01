//// World Definition
//// 
//// Defines all rooms, descriptions, exits, and items that make up
//// the game world. `initial_world` returns the complete list of rooms.

import game.{
  type Room, Description, East, Exit, Item, North, Room, RoomName, South, West,
}

/// Name of the room where the player begins the game
pub const starting_room = "Kaer Morhen Gate"

/// Construct and return the full list of rooms in the world
pub fn initial_world() -> List(Room) {
  let gate =
    Room(
      name: RoomName("Kaer Morhen Gate"),
      description: Description(
        "The old keep’s weathered entrance, battered by countless winters.",
      ),
      exits: [
        Exit(North, RoomName("Training Yard")),
        Exit(East, RoomName("Old Armory")),
        Exit(West, RoomName("Keep Courtyard")),
      ],
      items: [Item("witcher medallion")],
    )
  let clearing =
    Room(
      name: RoomName("Training Yard"),
      description: Description(
        "Weathered practice dummies and broken swords lie scattered across the packed earth.",
      ),
      exits: [
        Exit(South, RoomName("Kaer Morhen Gate")),
        Exit(East, RoomName("Old Armory")),
      ],
      items: [Item("broken training sword")],
    )
  let armory =
    Room(
      name: RoomName("Old Armory"),
      description: Description(
        "Dusty racks of weathered blades and dented shields line the cold stone walls.",
      ),
      exits: [Exit(West, RoomName("Training Yard"))],
      items: [Item("rusty short sword")],
    )
  let courtyard =
    Room(
      name: RoomName("Keep Courtyard"),
      description: Description(
        "A broad stone courtyard, echoes of old training sessions lingering in the cold air.",
      ),
      exits: [Exit(East, RoomName("Kaer Morhen Gate"))],
      items: [Item("weathered practice shield")],
    )
  let forge =
    Room(
      name: RoomName("Witcher's Forge"),
      description: Description(
        "The heat of the coals mixes with the scent of oils and steel — a place where blades are reborn.",
      ),
      exits: [
        Exit(West, RoomName("Old Armory")),
        Exit(North, RoomName("Keep Courtyard")),
      ],
      items: [Item("tempered steel ingot")],
    )

  let library =
    Room(
      name: RoomName("Kaer Morhen Library"),
      description: Description(
        "Dusty tomes and brittle scrolls detailing monster lore fill towering wooden shelves.",
      ),
      exits: [
        Exit(South, RoomName("Training Yard")),
        Exit(East, RoomName("Battlements")),
      ],
      items: [Item("ancient bestiary")],
    )

  let battlements =
    Room(
      name: RoomName("Battlements"),
      description: Description(
        "High atop the old keep, the wind cuts cold as you overlook the valley below.",
      ),
      exits: [
        Exit(West, RoomName("Kaer Morhen Library")),
        Exit(South, RoomName("Keep Courtyard")),
      ],
      items: [Item("eagle feather")],
    )

  [clearing, armory, gate, courtyard, forge, library, battlements]
}
