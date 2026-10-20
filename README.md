# Procedural Content Generation using Wave Function Collapse

This project was developed as part of my Computing Science final-year dissertation at the University of Malta. It explores how the Wave Function Collapse algorithm (WFC) can be used to generate connected playable dungeon layouts for a video game.

WFC is a constraint-based procedural generation algorithm meaning the main problem for this project was defining rules that would result in many connected rooms that would in turn form a dungeon.
More on this topic in my Dissertation.

The game prototype itself was is a 2D dungeon crawler that makes it possible to walk through generated rooms, pick up items, encounter enemies, inspect the minimap and influence how the rooms are generated.


## Features
**Room-based Wave-Function Collapse** builds a dungeon using room archetypes, domain reduction, minimum-entropy selection and constraint propagation.
**Three different generation styles** the prototype features 3 styles: 'CORRIDOR', 'BRANCHY' and 'VERTICAL', these styles influence room selection through weighted archetypes.
**Two dungeon size settings** By pressing 'B' in the games menu the player can either generate a 20 room dungeon or a 90 room one.
**Locked gateway mode** Optionally the generator can produce two sub-dungeons separated by a locked gateway, in order to enter through the gateway the player has to pick up a key.
**Evaluation tools** the project features dungeon metrics, generation seeds, and batch export to CSV for comparing generated structures.

## Requirements
-[Gamemaker](https://gamemaker.io/en)

## How to run
1. Download or clone this repo.
2. open the gamemaker project file: `PGC_game_regions_same size/PGC_game_regions_same size.yyp`.
3. Run the game by pressing F5.
4. Choose your generation setting by inputing 1,2 or 3, and press Enter

## How the generator works

### 1. Dungeon representation
The dungeon is stored as a graph of rooms placed on a coordinate-grid. Every room has an assigned coordinate grid like (1,-3), as well as a four-bit door mask that describes the number and position of doors in a room.

| Direction | Bit value |
| --- | ---: |
| North | `1` |
| East | `2` |
| South | `4` |
| West | `8` |

So for example a room with a a door to the north and a door to the south would have a mask `5` since `1 + 4 =5`.
Spatially adjacent rooms aren't automatically connected: a passage exists only when the door masks agree on both sides.

### 2. Collapsing and propagating constraints

The generator starts at room `0,0` and gradually grows an irregular dungeon graph:

1. **Initialize domains:** each unresolved room has a set of possible door configurations.
2. **Select a room:** prefer an unresolved room with the fewest remaining possibilities (minimum entropy).
3. **Collapse:** select an allowed archetype using weights determined by the active generation style.
4. **Propagate:** remove incompatible archetypes from neighbouring rooms' domains so door connections remain consistent.
5. **Validate:** reject unsuitable layouts and retry generation where necessary.

This process results in an abstract room layout.

### Shaping the dungeon using styles

While all 3 generation styles use the same underlying WFC logic, they differ in which room archetypes are more likely to be selected.

| Style | Design goal |
| --- | --- |
| `CORRIDOR` | Prefer straight corridors and more linear exploration |
| `BRANCHY` | Prefer junctions, and crossings |
| `VERTICAL` | Encourage more north–south connections and vertically oriented layouts |

### 4. Locked gateway mode

With locked gateway mode enabled, the generator first builds a smaller WFC dungeon that contains the starting room and a reachable key in one of the rooms. A gateway is then attached.

Afterwards a second dungeon is generated, this dungeon avoids overlapping rooms from the first dungeon, and connects to the first dungeon only through the locked gateway.

## Project status 

The core dungeon-generation system and playable demonstration were developed for the dissertation.
The game itself is very rough around the edges, and serves more as a visualisation of the generated dungeon, rather than an actual video-game.... perhaps someday.
All the sprites were made by me and while they aren't very beautiful i myself warmed up to them during the development and find them quite charming.





 
