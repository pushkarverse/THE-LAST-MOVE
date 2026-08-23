# The Last Move

**The Last Move** is an engaging 2D pixel-art platformer built in Godot 4.3. The game combines challenging platforming with mysterious thematic elements, featuring unique stage transitions, varying environments, and risk/reward mechanics.

## 🌟 Features

- **Dynamic Platforming**: Fluid character movement including running, jumping, and double-jumping to navigate treacherous gaps and hazards.
- **Thematic Worlds**: Journey through distinct environments:
  - **Room 01**: The classic starting grounds.
  - **Room 02**: A snowy, high-altitude obstacle course with wide staircase platforms.
  - **Room 03**: The latest addition, featuring advanced mechanics and power-ups.
- **The Gate of Fate**: A unique progression system. Reaching the end of a level triggers a high-stakes "Coin Toss" cinematic where your luck decides whether you advance safely or face the consequences of the "Hell Transition".
- **Collectibles & Hazards**: Gather Gems for score and Mystery Boxes for unknown rewards, but watch out for deadly Spikes and bottomless pits!
- **Dynamic HUD**: Tracks your current Score, remaining Hearts (Lives), and the current Level you are traversing.
- **Custom Audio Manager**: A fully integrated global audio system managing background music (BGM) fading and retro 8-bit sound effects.

## 📁 Project Structure

The project is organized cleanly using Godot best practices:

- `assets/`: Contains all visual assets, including the Kenney Pixel Platformer tilesets, UI packs, and environment backgrounds (like the custom moon and skies).
- `audio/`: Stores all music (`.ogg`) and sound effects (`.wav`, `.flac`, `.mp3`) used by the global `AudioManager`.
- `levels/`: The main level scenes (`room_01.tscn`, `room_02.tscn`, `room_03.tscn`).
- `scenes/`: Reusable packed scenes (prefabs) broken down into subfolders:
  - `cinematics/`: The Coin Toss and Hell Transition sequences.
  - `hazards/`: Spikes, moving platforms, and disappearing platforms.
  - `interactables/`: Gems, Mystery Boxes, and the Gate of Fate.
  - `player/`: The main player character.
  - `ui/`: The HUD and Loading Screens.
- `scripts/`: The GDScript files that power the game. Includes standard node scripts as well as global Singletons/Autoloads (`game_state.gd`, `audio_manager.gd`).

## 🎮 How to Play

- **Move**: `A` / `D` or `Left Arrow` / `Right Arrow`
- **Jump**: `Space` (Press again in the air to Double Jump)
- **Objective**: Navigate the obstacles, collect gems to increase your score, and reach the **Gate of Fate** at the end of each room. Win the coin toss to safely proceed to the next world!

## 🛠️ Development Setup

1. Clone or download the repository.
2. Open **Godot Engine 4.3** (or later compatible 4.x version).
3. Import the `project.godot` file.
4. Open `levels/room_01.tscn` (or press `F5` to run the main scene).

### Modifying Levels
- **Room 01** & **Room 03** are built using standard Godot `TileMapLayer` editing.
- **Room 02** features a procedural terrain generation script (`room_02.gd`) which draws the platforms and gaps on `_ready()`, allowing for rapid layout iteration via code!

## 📄 Assets & Credits

- **Visuals**: Modified assets from the [Kenney Pixel Platformer](https://kenney.nl/) and [Kenney Pixel UI](https://kenney.nl/) packs.
- **Character Sprite**: The player character uses the "Girl_2" sprite pack (located in `assets/characters/Girl_2/`), featuring full animations for idle, running, jumping, and interacting.
- **Audio**: Custom retro 8-bit sound effects and BGM.
- **Engine**: Built with [Godot 4.3](https://godotengine.org/).
