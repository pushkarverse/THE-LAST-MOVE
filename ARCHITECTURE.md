# THE LAST MOVE — Technical Architecture

## 1. Purpose

This document defines how the codebase for **The Last Move** should be structured.

It explains:

* How the game systems communicate
* Where different types of code belong
* How rooms are loaded
* How the game state changes
* How traps are triggered
* How player input is processed
* How the fake victory and Last Move systems work
* How new rooms can be added without rewriting the engine

For gameplay rules and design philosophy, refer to:

```text
DESIGN_MECHANISM.md
```

---

# 2. Technology Stack

Current project stack:

```text
Language        → TypeScript
Build Tool      → Vite
Package Manager → pnpm
Rendering       → Browser / Canvas-based game layer
Level Data      → JSON / TypeScript configuration
Platform        → Web
Targets         → Desktop + Mobile
```

The architecture should remain lightweight enough for rapid hackathon development.

---

# 3. Core Architecture Principle

The game should be divided into independent systems.

```text
INPUT
  ↓
PLAYER
  ↓
GAME STATE
  ↓
LEVEL
  ↓
EXIT
  ↓
FAKE VICTORY
  ↓
LAST MOVE
  ↓
TRAP
  ↓
RESULT
 ┌──────────────┐
 ↓              ↓
SURVIVE        DIE
 ↓              ↓
NEXT ROOM      RESTART
```

Each system should have one clear responsibility.

Avoid putting the entire game inside one large file.

---

# 4. Recommended Project Structure

```text
THE-LAST-MOVE/
│
├── public/
│   │
│   ├── rooms/
│   │   ├── world-1/
│   │   └── world-2/
│   │
│   ├── images/
│   ├── audio/
│   └── fonts/
│
├── src/
│   │
│   ├── game/
│   │   ├── Game.ts
│   │   ├── GameLoop.ts
│   │   └── GameState.ts
│   │
│   ├── player/
│   │   ├── Player.ts
│   │   └── PlayerController.ts
│   │
│   ├── levels/
│   │   ├── LevelManager.ts
│   │   ├── LevelTypes.ts
│   │   └── levelRegistry.ts
│   │
│   ├── traps/
│   │   ├── Trap.ts
│   │   ├── TrapManager.ts
│   │   └── trapTypes/
│   │
│   ├── systems/
│   │   ├── InputSystem.ts
│   │   ├── ScoreSystem.ts
│   │   ├── LivesSystem.ts
│   │   ├── TimerSystem.ts
│   │   └── TrustMeter.ts
│   │
│   ├── ui/
│   │   ├── HUD.ts
│   │   ├── FakeVictoryScreen.ts
│   │   ├── DeathScreen.ts
│   │   └── GameOverScreen.ts
│   │
│   ├── audio/
│   │   └── AudioManager.ts
│   │
│   ├── config/
│   │   └── gameConfig.ts
│   │
│   ├── utils/
│   │   └── helpers.ts
│   │
│   └── main.ts
│
├── tools/
│
├── README.md
├── DESIGN_MECHANISM.md
├── ARCHITECTURE.md
├── LEVEL_DESIGN.md
│
├── package.json
├── pnpm-lock.yaml
├── pnpm-workspace.yaml
├── tsconfig.json
├── vite.config.ts
└── index.html
```

This structure may evolve as development continues.

Do not create empty files simply to match this diagram. Add modules when they become necessary.

---

# 5. `main.ts`

`main.ts` should remain small.

Its job is only to initialize the application.

Conceptually:

```ts
import { Game } from "./game/Game";

const game = new Game();

game.start();
```

Avoid putting:

* Trap logic
* Player movement
* Level definitions
* UI logic
* Score calculations

directly inside `main.ts`.

---

# 6. Game Controller

`Game.ts` acts as the central coordinator.

It should connect the major systems without implementing every feature itself.

Example responsibilities:

```text
Game
│
├── Initialize systems
├── Load first room
├── Start game loop
├── Manage global state
├── Coordinate level transitions
└── Pause / resume game
```

Conceptually:

```ts
class Game {
  start() {
    this.levelManager.loadLevel("world-1-level-1");
    this.gameLoop.start();
  }
}
```

---

# 7. Game State

The game should use a clear state machine.

```ts
export type GameState =
  | "START"
  | "PLAYING"
  | "EXIT_REACHED"
  | "FAKE_COMPLETE"
  | "LAST_MOVE"
  | "SURVIVED"
  | "DEAD"
  | "PAUSED"
  | "GAME_OVER";
```

Typical flow:

```text
START
  ↓
PLAYING
  ↓
EXIT_REACHED
  ↓
FAKE_COMPLETE
  ↓
LAST_MOVE
  ↓
 ┌──────────────┐
 ↓              ↓
SURVIVED       DEAD
 ↓              ↓
NEXT ROOM      RESTART
```

The state machine prevents different parts of the game from running at the wrong time.

---

# 8. Game Loop

`GameLoop.ts` controls continuous game updates.

Typical responsibilities:

```text
Read Input
    ↓
Update Player
    ↓
Update Room
    ↓
Update Trap
    ↓
Check Collisions
    ↓
Update UI
    ↓
Render Frame
```

Conceptually:

```ts
function update(deltaTime: number) {
  updateInput();
  updatePlayer(deltaTime);
  updateLevel(deltaTime);
  updateTraps(deltaTime);
  checkCollisions();
  updateUI();
}
```

Rendering and game logic should remain separated whenever practical.

---

# 9. Level Manager

`LevelManager.ts` is responsible for rooms.

It should:

* Load room data
* Spawn room objects
* Position the player
* Create the exit
* Configure the Last Move
* Configure traps
* Restart the current room
* Load the next room

Conceptually:

```text
LEVEL DATA
    ↓
LEVEL MANAGER
    ↓
CREATE ROOM
    ↓
CREATE EXIT
    ↓
CREATE TRAP
    ↓
START LEVEL
```

The Level Manager should not contain unique hard-coded logic for every room.

---

# 10. Data-Driven Levels

Rooms should be described using structured data whenever possible.

Example:

```ts
interface LevelConfig {
  id: string;
  world: number;
  room: number;
  name: string;

  timeLimit: number;

  playerSpawn: {
    x: number;
    y: number;
  };

  exit: {
    x: number;
    y: number;
  };

  lastMove: {
    trap: string;
    correctAction: LastMoveAction;
    delay: number;
    duration?: number;
    telegraph?: string;
  };
}
```

Example room:

```json
{
  "id": "world-1-level-2",
  "world": 1,
  "room": 2,
  "name": "Don't Celebrate Yet",

  "timeLimit": 60,

  "playerSpawn": {
    "x": 80,
    "y": 420
  },

  "exit": {
    "x": 850,
    "y": 420
  },

  "lastMove": {
    "trap": "FALLING_BLOCK",
    "correctAction": "MOVE_LEFT",
    "delay": 2000,
    "telegraph": "CEILING_SHAKE"
  }
}
```

This allows new rooms to be created mostly through configuration.

---

# 11. Level Registry

A central level registry should determine progression.

Example:

```ts
export const levelRegistry = [
  "world-1-level-1",
  "world-1-level-2",
  "world-1-level-3",
  "world-1-level-4",
  "world-1-level-5"
];
```

The game can then determine:

```text
CURRENT ROOM
     ↓
SURVIVED
     ↓
NEXT ENTRY
     ↓
LOAD NEXT ROOM
```

---

# 12. Player System

`Player.ts` stores player state.

Example:

```ts
interface PlayerState {
  x: number;
  y: number;

  velocityX: number;
  velocityY: number;

  isAlive: boolean;
  isGrounded: boolean;
}
```

`PlayerController.ts` should handle actions such as:

```text
Move Left
Move Right
Jump
Interact
Stop
```

The player system should not decide whether an action is correct for a Last Move.

That responsibility belongs to the Last Move / trap logic.

---

# 13. Input System

`InputSystem.ts` should convert keyboard, touch, and pointer events into game actions.

Example:

```ts
type PlayerAction =
  | "MOVE_LEFT"
  | "MOVE_RIGHT"
  | "JUMP"
  | "INTERACT"
  | "NONE";
```

Conceptually:

```text
KEYBOARD
    ┐
TOUCH
    ├──→ INPUT SYSTEM → PLAYER ACTION
POINTER
    ┘
```

This prevents desktop and mobile controls from requiring separate gameplay logic.

---

# 14. Mobile Input Protection

Operating-system interactions must not automatically count as gameplay actions.

The Input System should distinguish between:

```text
GAME INPUT
```

and:

```text
DEVICE / BROWSER INPUT
```

Events such as:

* Window losing focus
* Browser tab switching
* Pointer cancellation
* OS notification interaction
* Edge gestures

should not automatically cause player death.

If the application loses focus:

```text
FOCUS LOST
    ↓
PAUSE
```

not:

```text
FOCUS LOST
    ↓
PLAYER DIES
```

---

# 15. Exit Detection

The exit system detects when the player reaches the apparent goal.

It should **not** directly load the next room.

Correct:

```text
PLAYER TOUCHES EXIT
        ↓
EXIT_REACHED
        ↓
FAKE VICTORY
```

Incorrect:

```text
PLAYER TOUCHES EXIT
        ↓
NEXT ROOM
```

This distinction is essential to the game.

---

# 16. Fake Victory Controller

The fake victory system handles:

```text
LEVEL COMPLETE
Victory sound
Confetti
Score animation
Continue prompt
Celebration delay
```

Its job is to create the illusion that the room is finished.

After the fake victory delay:

```text
FAKE_COMPLETE
      ↓
LAST_MOVE
```

The Fake Victory Controller should not contain trap-specific logic.

---

# 17. Last Move Controller

The Last Move Controller determines the final challenge.

Responsibilities:

* Read the current room's Last Move configuration
* Activate the telegraph
* Activate the trap
* Monitor player behaviour
* Determine whether the sequence succeeded
* Trigger survival or death

Conceptually:

```text
LEVEL CONFIG
     ↓
LAST MOVE CONTROLLER
     ↓
TELEGRAPH
     ↓
TRAP
     ↓
PLAYER RESPONSE
     ↓
RESULT
```

---

# 18. Last Move Actions

Supported actions may include:

```ts
export type LastMoveAction =
  | "MOVE_LEFT"
  | "MOVE_RIGHT"
  | "JUMP"
  | "WAIT"
  | "INTERACT"
  | "DO_NOT_TOUCH";
```

The system should allow additional actions to be added later without redesigning the whole engine.

---

# 19. Trap System

Each trap should have a common interface.

Example:

```ts
interface Trap {
  activate(): void;
  update(deltaTime: number): void;
  reset(): void;
  destroy(): void;
}
```

Trap examples:

```text
FallingBlockTrap
FakeButtonTrap
ChargingEnemyTrap
UnstableFloorTrap
MovingWallTrap
FalseExitTrap
```

A `TrapManager` can create the correct trap based on room configuration.

Example:

```text
"FALLING_BLOCK"
       ↓
TRAP MANAGER
       ↓
FallingBlockTrap
```

---

# 20. Prefer Physical Consequences

Whenever possible, the trap itself should cause death.

Prefer:

```text
BLOCK FALLS
    ↓
COLLIDES WITH PLAYER
    ↓
PLAYER DIES
```

over:

```ts
if (wrongAction) {
  killPlayer();
}
```

This makes failures visually understandable.

The player should see **why** they died.

---

# 21. Room 1-1 Tutorial Exception

Room `1-1` contains the forced first tutorial death.

This behaviour should come from room configuration instead of being scattered throughout the code.

Example:

```json
{
  "tutorial": {
    "forcedFailure": true,
    "firstAttemptOnly": true,
    "consumeLife": false,
    "countDeath": false,
    "affectTrustMeter": false
  }
}
```

The Level Manager can check:

```ts
if (
  level.tutorial?.forcedFailure &&
  attemptNumber === 1
) {
  triggerTutorialDeath();
}
```

After the first attempt, the room should behave normally.

---

# 22. Lives System

`LivesSystem.ts` should be responsible only for lives.

Example:

```ts
class LivesSystem {
  private lives = 3;

  loseLife() {
    this.lives--;
  }

  reset() {
    this.lives = 3;
  }
}
```

Other systems should request a life change instead of modifying the value directly.

---

# 23. Score System

`ScoreSystem.ts` manages scoring.

Possible scoring sources:

```text
Room completion
Last Move survival
Speed bonus
First-attempt survival
Remaining lives
```

Example:

```ts
scoreSystem.add(1000);
```

Avoid manipulating the score directly from unrelated files.

---

# 24. Timer System

`TimerSystem.ts` should manage:

* Room timer
* Pause
* Resume
* Reset
* Timeout

Example:

```text
START ROOM
    ↓
START TIMER
    ↓
PAUSE IF GAME PAUSED
    ↓
STOP ON DEATH / SURVIVAL
```

Timers for specific traps can remain inside the trap or Last Move system.

---

# 25. Trust Meter

`TrustMeter.ts` is an advanced system.

Possible information:

```ts
interface PlayerBehaviour {
  averageReactionTime: number;
  immediateMovementRate: number;
  hesitationRate: number;
  deaths: number;
}
```

Initially, it may simply collect information.

Adaptive difficulty should be added only after the core gameplay works reliably.

---

# 26. UI System

UI code should remain separate from gameplay logic.

Suggested components:

```text
HUD
FakeVictoryScreen
DeathScreen
GameOverScreen
PauseScreen
```

For example:

```text
GAME STATE
    ↓
UI SYSTEM
    ↓
DISPLAY CORRECT SCREEN
```

The UI should react to game state instead of controlling the game state directly wherever possible.

---

# 27. HUD

The HUD should receive values from game systems.

Example:

```text
WORLD 1-3
SCORE 004800
♥ ♥ ♥
TIME 045
```

Data flow:

```text
ScoreSystem ──┐
LivesSystem ──┼──→ HUD
TimerSystem ──┤
LevelManager ─┘
```

The HUD should display information, not calculate it.

---

# 28. Audio Manager

`AudioManager.ts` should handle:

* Background music
* Victory sound
* Death sound
* Trap sounds
* UI sounds
* Warning telegraphs

Example:

```ts
audioManager.play("victory");
audioManager.play("ceiling-rumble");
```

This prevents sound-loading code from being repeated throughout the project.

---

# 29. Pause System

The game should support a global pause.

Pause conditions may include:

```text
Escape pressed
Browser loses focus
Page becomes hidden
Mobile interruption
```

While paused:

```text
Player movement     → STOP
Room timer          → PAUSE
Trap timers         → PAUSE
Game simulation     → PAUSE
```

The player should never die because the browser temporarily lost focus.

---

# 30. Room Restart

Restarting should reset all room-specific state.

```text
DEATH
  ↓
RESET PLAYER
RESET TRAPS
RESET TIMER
RESET EXIT
RESET LAST MOVE
CLEAR INPUT
  ↓
PLAYING
```

Global information such as:

```text
Lives
Score
Tutorial progress
```

should only reset when appropriate.

---

# 31. System Communication

Avoid allowing every system to modify every other system directly.

Prefer clear communication.

Example:

```text
Trap detects collision
        ↓
Game receives death event
        ↓
LivesSystem updates
        ↓
UI updates
        ↓
Level restarts
```

This is cleaner than allowing:

```text
Trap
 ↓
changes player
changes score
changes UI
changes lives
restarts room
changes timer
```

all by itself.

---

# 32. Dependency Direction

Prefer this dependency direction:

```text
Game
 ↓
Managers / Systems
 ↓
Entities / Components
 ↓
Utility functions
```

Avoid circular dependencies such as:

```text
Player imports TrapManager
TrapManager imports Player
```

Whenever possible, communicate through:

* Function calls
* Events
* Shared interfaces
* Game controller

---

# 33. Configuration

Global values should live in a central configuration file.

Example:

```ts
export const GAME_CONFIG = {
  startingLives: 3,
  defaultRoomTime: 60,
  fakeVictoryDelay: 1500,
  mobileEnabled: true
};
```

This avoids repeating magic values such as:

```ts
1500
60
3
```

throughout the codebase.

---

# 34. Asset Organization

Game assets should remain organized.

Recommended:

```text
public/
│
├── images/
│   ├── player/
│   ├── traps/
│   ├── rooms/
│   └── ui/
│
├── audio/
│   ├── music/
│   ├── effects/
│   └── ui/
│
└── fonts/
```

Avoid putting every asset directly inside `public/`.

---

# 35. Error Handling

Development errors should be visible and understandable.

Example:

```ts
if (!levelData) {
  throw new Error(`Level not found: ${levelId}`);
}
```

Do not silently ignore important errors.

Development logs may use:

```ts
console.log();
console.warn();
console.error();
```

but unnecessary debugging logs should be removed before the final demo.

---

# 36. Naming Conventions

Recommended naming:

### Classes

```text
Game
Player
LevelManager
TrapManager
InputSystem
```

### Files

```text
Game.ts
Player.ts
LevelManager.ts
```

### Variables and functions

```ts
playerPosition
currentLevel
startLastMove()
restartRoom()
```

### Constants

```ts
MAX_LIVES
DEFAULT_TIME_LIMIT
FAKE_VICTORY_DELAY
```

Keep naming consistent throughout the project.

---

# 37. TypeScript Rules

Prefer explicit types for important game data.

Good:

```ts
interface Position {
  x: number;
  y: number;
}
```

Avoid excessive use of:

```ts
any
```

The project should maintain:

```json
"strict": true
```

in `tsconfig.json`.

TypeScript should help catch bugs before the game runs.

---

# 38. Avoid Hard-Coding Rooms

Avoid:

```ts
if (level === 1) {
  createFallingBlock();
}

if (level === 2) {
  createEnemy();
}

if (level === 3) {
  createFakeButton();
}
```

Prefer:

```ts
loadLevel(levelData);
```

where room configuration determines:

```text
Trap
Telegraph
Correct action
Timing
Spawn position
Exit position
Rewards
Tutorial behaviour
```

This is one of the most important architecture rules.

---

# 39. Adding a New Room

Ideally, creating a new room should require:

### Step 1

Create the room configuration.

### Step 2

Select an existing trap.

### Step 3

Set the telegraph.

### Step 4

Set the correct Last Move.

### Step 5

Add the room to the level registry.

Example:

```text
CREATE LEVEL DATA
      ↓
REGISTER LEVEL
      ↓
RUN GAME
```

A new room should not require major engine changes unless it introduces an entirely new mechanic.

---

# 40. MVP Architecture Priority

Build systems in this order:

```text
1. Game State
      ↓
2. Game Loop
      ↓
3. Player Movement
      ↓
4. Level Loading
      ↓
5. Exit Detection
      ↓
6. Fake Victory
      ↓
7. Last Move
      ↓
8. Trap System
      ↓
9. Death / Restart
      ↓
10. Lives + Score + Timer
      ↓
11. UI Polish
      ↓
12. Advanced Features
```

Do not begin advanced systems before the core loop works.

---

# 41. Features That Should Remain Optional Initially

The architecture may support these later:

```text
Trust Meter adaptation
Rage Cam
Video exporting
Leaderboard
Cloud saves
Analytics
Social sharing
Multiple worlds
Achievements
```

They should not complicate the MVP architecture.

---

# 42. Core Data Flow

The complete runtime flow should approximately be:

```text
USER INPUT
    ↓
INPUT SYSTEM
    ↓
PLAYER CONTROLLER
    ↓
PLAYER
    ↓
LEVEL MANAGER
    ↓
EXIT DETECTION
    ↓
GAME STATE
    ↓
FAKE VICTORY
    ↓
LAST MOVE CONTROLLER
    ↓
TRAP MANAGER
    ↓
COLLISION / ACTION CHECK
    ↓
 ┌────────────────────┐
 ↓                    ↓
SURVIVED              DEAD
 ↓                    ↓
SCORE                  LIFE LOST
 ↓                    ↓
NEXT ROOM              RESTART
```

---

# 43. Architecture Rule of Responsibility

Each module should answer one main question.

```text
Game.ts
→ What is happening globally?

GameState.ts
→ What phase is the game currently in?

Player.ts
→ What is the player's state?

PlayerController.ts
→ What is the player trying to do?

InputSystem.ts
→ What input did the user provide?

LevelManager.ts
→ Which room is loaded?

TrapManager.ts
→ Which trap should run?

Last Move Controller
→ What happens after the fake victory?

LivesSystem.ts
→ How many lives remain?

ScoreSystem.ts
→ What is the player's score?

TimerSystem.ts
→ How much time remains?

HUD.ts
→ What information should be displayed?
```

If one file starts answering too many of these questions, it should probably be split.

---

# 44. Final Architecture Principle

The architecture of **The Last Move** should preserve one essential distinction:

```text
REACH EXIT
    ↓
APPARENT VICTORY
```

is different from:

```text
SURVIVE LAST MOVE
    ↓
ACTUAL VICTORY
```

Technically:

```text
EXIT_REACHED
      ↓
FAKE_COMPLETE
      ↓
LAST_MOVE
      ↓
SURVIVED
```

Only the `SURVIVED` state should allow progression to the next room.

> **The exit starts the ending. The Last Move decides whether the player actually wins.**

----------------------------------------------------------------------------------------------------
## THE FINAL ARCHITECTURAL FIGURE:

src/
│
├── game/
│   ├── Game.ts
│   ├── GameLoop.ts
│   ├── GameState.ts
│   └── LastMoveController.ts
│
├── player/
│   ├── Player.ts
│   └── PlayerController.ts
│
├── levels/
│   ├── LevelManager.ts
│   ├── LevelTypes.ts
│   └── levelRegistry.ts
│
├── traps/
│   ├── Trap.ts
│   ├── TrapManager.ts
│   └── trapTypes/
│
├── systems/
│   ├── InputSystem.ts
│   ├── CollisionSystem.ts
│   ├── ScoreSystem.ts
│   ├── LivesSystem.ts
│   ├── TimerSystem.ts
│   └── TrustMeter.ts
│
├── rendering/
│   └── Renderer.ts
│
├── ui/
│   ├── HUD.ts
│   ├── FakeVictoryScreen.ts
│   ├── DeathScreen.ts
│   └── GameOverScreen.ts
│
├── audio/
│   └── AudioManager.ts
│
├── storage/
│   └── ProgressManager.ts
│
├── config/
│   └── gameConfig.ts
│
├── utils/
│   └── helpers.ts
│
└── main.ts
