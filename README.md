# The Last Move

A pixel-art platformer adventure built with Godot.

---

# 🎨 Assets & Credits

This project uses a combination of third-party game-development assets,
open-source resources, existing asset packs, and custom game-specific
implementations.

All third-party assets remain subject to their respective creators'
licenses. Please refer to the original source and license information
before redistributing individual assets separately from this project.

---

## 🧱 Pixel Art Assets

### Kenney — Pixel Platformer

A significant portion of the game's visual foundation is based on
assets from Kenney's Pixel Platformer asset collection.

**Creator:** Kenney  
**Website:** https://kenney.nl/  
**Asset Collection:** Pixel Platformer  
**License:** Creative Commons Zero (CC0 1.0)

The Pixel Platformer collection is used as the visual foundation for
various elements of the game, including:

- Pixel-art terrain
- Ground tiles
- Platform tiles
- Floating platforms
- Environmental tiles
- Decorative objects
- Collectible objects
- Gameplay objects
- Character-related assets
- Hazard-related assets
- UI-related elements
- Environmental decorations
- Pixel-art world-building elements

Kenney's assets are released under CC0, meaning attribution is not
required, although credit is provided here as a courtesy.

Official asset source:

https://kenney.nl/assets/pixel-platformer

---

## 🧱 Pixel Platformer Blocks

Where applicable, assets from Kenney's Pixel Platformer Blocks collection
are used for additional level construction and environment elements.

**Creator:** Kenney  
**License:** Creative Commons Zero (CC0 1.0)

The collection may be used for:

- Additional platform pieces
- Terrain construction
- Blocks
- Level geometry
- Environmental structures
- Decorative blocks
- World-building elements

Official source:

https://kenney.nl/assets/pixel-platformer-blocks

---

# 🌎 Environment Assets

The game uses pixel-art environment assets to construct its different
worlds and stages.

Environment assets include elements such as:

- Ground
- Grass
- Dirt
- Platforms
- Floating platforms
- Terrain edges
- Terrain decorations
- Trees
- Plants
- Rocks
- Environmental props
- Background elements
- Decorative objects
- World-specific structures
- Level-ending structures
- Gates and doors
- Mystery objects
- Environmental details

The environment is assembled and arranged specifically for the levels
in this project.

---

# 🗺️ Level Design

The individual level layouts are custom-designed for this project.

This includes:

- Platform placement
- Terrain layout
- Jump sequences
- Hazard placement
- Collectible placement
- Moving-platform placement
- Player routes
- Secret/mystery areas
- Gate locations
- Level progression
- Difficulty progression
- Environmental decoration
- Background composition
- Level pacing

The third-party assets are used as building blocks, while their
arrangement and gameplay implementation are specific to this project.

---

# 🎮 Player & Character Assets

The game uses pixel-art character assets for the playable character.

The player character is integrated into a custom gameplay system
including:

- Walking
- Running
- Jumping
- Falling
- Landing
- Direction changes
- Animation states
- Collision
- Death
- Respawning
- Interaction
- Gate interaction
- Cinematic sequences

The gameplay behavior and integration are custom implementations for
this project.

---

# ❤️ HUD & User Interface

The game contains a custom gameplay HUD.

The HUD includes:

- Heart/life display
- Score display
- Level indicator
- Collectible feedback
- Heart-loss animation
- Game Over interface
- Restart prompt
- Coin-toss interface
- Heads/Tails selection
- Countdown timer
- Cinematic dialogue
- Event/result displays

The primary gameplay HUD is structured as:

    ❤️ ❤️ ❤️                 LEVEL: 1                 SCORE: 0000

The HUD remains fixed to the screen while the game world and camera move
independently.

---

# ❤️ Health / Lives System

The game includes a three-heart health/lives system.

The player begins gameplay with:

    ❤️ ❤️ ❤️

When the player dies:

    ❤️ ❤️ ❤️
       ↓
    ❤️ ❤️
       ↓
    ❤️
       ↓
    GAME OVER

The system includes:

- Heart-loss detection
- Heart-loss animation
- Death handling
- Respawn handling
- Score penalty
- Game Over detection
- Restart functionality

---

# 💎 Collectibles & Score

The game contains collectible objects that contribute to the player's
score.

The score system includes:

- Collectible detection
- Point assignment
- Score updates
- Score animation
- HUD synchronization
- Death score penalty
- Score reset/reinitialization

The score is displayed using a fixed HUD element.

Example:

    SCORE: 0000
    SCORE: 0100
    SCORE: 0250
    SCORE: 1000

---

# ⚠️ Hazards

The game includes environmental hazards used to create platforming
challenges.

These include elements such as:

- Spikes
- Hazard collision areas
- Death boxes
- Dangerous gaps
- Environmental death zones
- Other stage-specific hazards

Hazards interact with the existing player death system.

Hazard interactions can trigger:

- Player death
- Heart reduction
- Death animation
- Score penalty
- Respawn
- Game Over

---

# 🌀 Moving Platforms

The game uses moving platforms to create additional platforming
challenges.

Moving platforms include:

- Horizontal movement
- Vertical movement
- Repeating movement
- Platform collision
- Player interaction
- Level-specific positioning

The platform layouts and movement patterns are configured specifically
for each stage.

---

# ☁️ Animated Background Environment

The game contains animated environmental background elements to make the
world feel alive.

Depending on the environment, these may include:

- Clouds
- Birds
- Atmospheric particles
- Environmental motion
- Background decorations
- Parallax elements

For outdoor environments:

- Clouds move from right to left.
- Birds move from left to right.
- Different elements use different speeds.
- Background elements loop continuously.
- Background elements remain behind gameplay.

These systems are implemented as decorative background systems and do not
interfere with gameplay collision.

---

# 🌳 Environmental Decoration

The game uses environmental props to make each stage visually distinct.

Examples include:

- Trees
- Plants
- Rocks
- Grass
- Background structures
- Decorative objects
- Mystery boxes
- Gates
- Doors
- World-specific props

Environmental objects are arranged specifically for each level.

---

# ❓ Mystery / Special Mystery Object

The game contains a special mystery interaction represented by a
question-mark box.

The level presents the object with a floating:

    Special Mystery?

label.

The label includes a subtle animation to make the object stand out.

---

# 🔑 Key & Gate System

The game contains a cinematic key-and-gate interaction.

When the player reaches the gate:

1. The player approaches the gate.
2. The player takes a key from their pocket.
3. The key is brought toward the lock.
4. The key enters the keyhole.
5. The player turns the key.
6. The lock mechanism activates.
7. The gate unlocks.
8. The gate opens.
9. The player enters.

The interaction includes synchronized visual and audio feedback.

---

# 🔊 Audio & Sound Effects

The game uses sound effects and music to provide feedback during gameplay
and cinematic sequences.

Audio categories include:

### Gameplay

- Walking sounds
- Footstep sounds
- Jump sounds
- Landing sounds
- Collectible sounds
- Hazard/death sounds
- Heart-loss sounds

### Gate Interaction

- Key extraction
- Key movement
- Key insertion
- Lock turning
- Lock clicking
- Gate unlocking
- Gate opening

### Coin Toss

- Choice confirmation
- Coin flip
- Coin movement
- Coin landing
- Result feedback
- Timer/ticking sounds

### Cinematic

- Devil appearance
- Ominous effects
- Transition effects
- Hell sequence
- Falling effects
- Death effects
- Game Over effects

All third-party audio remains subject to the license of its respective
creator/source.

---

# 🎵 Music

The game contains separate audio states for gameplay and Game Over.

Gameplay music is used during normal level gameplay.

Game Over music is used during the Game Over sequence.

The audio system prevents multiple music tracks from playing
simultaneously.

When the player presses `R` to restart after Game Over:

1. Game Over music fades/stops.
2. Game Over audio state is cleared.
3. The current level restarts.
4. Normal gameplay music returns.
5. Gameplay music fades in smoothly.

This prevents Game Over music from continuing into the restarted level.

---

# 😈 Gate of Fate

The end of the stage contains a special cinematic event known as the
**Gate of Fate**.

The Gate of Fate is a progression system that separates the normal
platforming section from the next stage.

The sequence includes:

- Gate interaction
- Key animation
- Lock interaction
- Gate opening
- Screen transition
- Devil appearance
- Dialogue
- Coin toss
- Player choice
- Countdown timer
- Weighted outcome
- Victory sequence
- Hell sequence
- Game Over

---

# 😈 Devil Encounter

After entering the Gate of Fate, the player encounters a Devil character.

The sequence is presented as a cinematic event.

The Devil:

- Appears on a dark screen
- Introduces the challenge
- Presents the coin toss
- Requests the player's choice
- Reacts to the result
- Allows progression after a successful result
- Sends the player toward Hell after failure

The encounter uses custom scene composition, animation, dialogue,
transitions and audio integration.

---

# 🪙 Coin Toss System

The Gate of Fate includes a Heads/Tails coin-toss challenge.

The interface is arranged as:

    HEADS          COIN          TAILS

The player selects:

- HEADS on the left
- TAILS on the right

The player has a limited amount of time to make a decision.

---

# ⏱️ Five-Second Decision Timer

The player has five seconds to select Heads or Tails.

The countdown is displayed during the selection phase:

    5
    4
    3
    2
    1

If the player does not select an option before the timer expires,
the event is treated as a loss.

The timer includes visual and audio feedback.

---

# 🎲 Gate of Fate Probability

The Gate of Fate uses a weighted outcome system.

The intended probability is:

    WIN  = 60%
    LOSS = 40%

The player's selection is compared against the resulting coin outcome.

Example:

    Player chooses HEADS
    Result = HEADS
    → WIN

or:

    Player chooses HEADS
    Result = TAILS
    → LOSS

Likewise:

    Player chooses TAILS
    Result = TAILS
    → WIN

or:

    Player chooses TAILS
    Result = HEADS
    → LOSS

The displayed coin result matches the actual game result.

---

# 🔥 Hell Sequence

If the player loses the Gate of Fate challenge, a cinematic Hell
sequence is triggered.

The sequence can include:

- Devil reaction
- Ominous transition
- Screen shake
- Portal/falling transition
- Dark environment
- Fire
- Lava
- Hell atmosphere
- Falling animation
- Player death
- Game Over

The Hell sequence is designed as a dramatic failure state rather than
an ordinary platforming death.

---

# ☠️ Game Over

The game contains a dedicated Game Over system.

When all three hearts are lost:

- Player control stops.
- Gameplay pauses/ends.
- Game Over UI appears.
- The scene transitions into a death state.
- Game Over audio plays.
- The player can restart.

The restart action is:

    R — Retry

The restart system restores the appropriate gameplay state and prevents
Game Over music from continuing into the restarted level.

---

# 🎬 Cinematic Transitions

The project uses cinematic transitions for major gameplay events.

These include:

- Level transitions
- Gate transitions
- Black-screen transitions
- Devil introduction
- Coin toss
- Hell transition
- Game Over
- Restart

Transitions use combinations of:

- Fades
- Animation
- UI
- Screen effects
- Audio
- Camera effects
- Sprite animation

---

# 🌍 Multiple Worlds / Levels

The game is designed around multiple rooms/stages.

Each stage maintains the same core gameplay systems while providing a
different world and level design.

### Room 1

Room 1 establishes the primary gameplay mechanics:

- Basic platforming
- Collectibles
- Hazards
- Moving platforms
- Mystery object
- HUD
- Hearts
- Score
- Gate
- Gate of Fate
- Devil
- Coin toss
- Hell sequence

### Room 2

Room 2 is designed as a new world with:

- Different environment
- Different visual identity
- Different terrain
- Different platform arrangement
- Different background
- Different atmosphere
- Different level layout
- Different challenge progression

The core gameplay systems remain consistent across stages.

---

# 🧩 Custom Game Systems

The following systems were implemented specifically for this project:

- Player controller integration
- Player death system
- Respawn system
- Three-heart system
- Heart-loss animation
- Score system
- Score penalty
- Collectible integration
- HUD
- Level indicator
- Game Over system
- Retry system
- Moving platform integration
- Hazard integration
- DeathBox interaction
- Mystery object interaction
- Gate interaction
- Key animation
- Lock interaction
- Gate opening sequence
- Gate of Fate
- Devil encounter
- Coin toss system
- Heads/Tails selection
- Five-second timer
- 60/40 weighted outcome
- Hell sequence
- Cinematic transitions
- Background cloud movement
- Bird movement
- Environmental animation
- Music state management
- Game Over music transition
- Level transition system

---

# 🛠️ Game Engine & Technology

### Godot Engine

The game is developed using **Godot Engine**.

Godot is used for:

- Scene management
- 2D rendering
- Physics
- Collision
- Animation
- UI
- Audio
- Input
- Level management
- Game state
- Scene transitions
- Particle effects
- Camera systems
- Scripting

Official website:

https://godotengine.org/

---

# 💻 Programming

The game's gameplay logic is implemented using Godot's scripting
environment.

Custom scripts are responsible for:

- Player movement
- Physics
- Level generation/management
- Collision
- Hazards
- Collectibles
- Score
- Health
- HUD
- Game State
- Gate interaction
- Coin toss
- Cinematic events
- Audio state
- Level transitions

---

# 🎨 Art Direction

The game follows a pixel-art platformer visual style.

The visual direction emphasizes:

- Pixel-art sprites
- Simple readable silhouettes
- Bright gameplay elements
- Strong environmental contrast
- Compact HUD
- Animated environmental details
- Distinct world themes
- Clear platform readability

Different worlds use different environmental palettes and asset
combinations while maintaining a consistent overall art style.

---

# 📝 Asset Licensing

Third-party assets included in this project remain the property of their
respective creators.

Assets are not being claimed as original creations by the developer of
this game.

Where a third-party license requires attribution, the relevant creator
and license information should be retained.

For assets released under CC0, such as Kenney's relevant asset packs,
attribution is not legally required, but credit is provided as a
courtesy.

Before redistributing the game's source files or individual third-party
assets separately, users should verify the license terms of each asset.

---

# 🙏 Special Thanks

Special thanks to:

### Kenney

For creating and providing high-quality game-development assets that
helped establish the visual foundation of this project.

Website:

https://kenney.nl/

Asset library:

https://kenney.nl/assets

---

# 📜 Third-Party Asset Notice

This project may contain third-party assets that are subject to their
own licenses.

Third-party assets should not be interpreted as being owned by the
developer of this project.

The developer's original contributions include the game's:

- Level design
- Game logic
- Gameplay systems
- Scene composition
- Interactions
- Game state
- UI implementation
- Cinematic sequences
- Progression systems
- Audio integration
- Level structure
- Custom scripting
- System integration

unless otherwise stated.

---

# ⚠️ License Verification

Asset sources and licenses should always be verified against the
original asset provider before commercial redistribution or publication.

If an asset's source or license cannot be determined, it should be
treated as:

**Source/license requires verification**

rather than assuming that the asset is free for redistribution.

---

# ❤️ Credits

Made with:

- Godot Engine
- Kenney game-development assets
- Third-party resources used under their respective licenses
- Custom gameplay systems
- Custom level design
- Custom scene composition
- Custom scripting and integration

Thank you to the creators of the open and freely available resources
that helped make this project possible.
