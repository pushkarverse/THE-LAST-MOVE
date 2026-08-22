THE LAST MOVE

You reached the exit. You won. Now make one final move.

THE LAST MOVE is a retro-inspired puzzle/troll game by Team Binary
Brains where reaching the exit is only the beginning. The game
deliberately creates a false sense of safety after a level appears to be
complete --- then challenges the player with one final decision.

The exit isn't the puzzle. The win screen is the boss.

🕹️ Game Concept

Most games teach players that once they reach the goal, they are safe.

THE LAST MOVE breaks that assumption.

Each room begins like a simple puzzle:

SOLVE --- Reach the exit.

COMPLETE --- The game celebrates with a win screen, fanfare, and
false safety.

LAST MOVE --- Move, wait, or don't touch anything.

SURVIVE --- Make the correct final decision or fall into the
trap.

Every trap is telegraphed. Nothing is random.

The objective is not just to solve the room --- it is to learn when
not to trust the win.

✨ Core Features

🚩 False Flag

Each room can present two apparent solutions. The obvious one may be the
wrong one.

🔀 Rule Mutation

The rule after the apparent win can change between rooms, preventing
players from relying on superstition instead of observation.

♥ Trust Meter

The game measures how quickly the player relaxes after reaching the goal
and can use that behavior to influence difficulty.

📹 Rage Cam

Player deaths can become short reaction clips designed for easy sharing.

⚡ Fast Rooms

Rooms are designed to take under 60 seconds, with each room
retraining one player instinct.

 The Core Loop

START
  ↓
SOLVE THE ROOM
  ↓
REACH THE EXIT
  ↓
"LEVEL COMPLETE"
  ↓
ONE FINAL MOVE
  ↓
MOVE / WAIT / DO NOTHING
  ↓
SURVIVE?
  ├── YES → NEXT ROOM
  └── NO  → RESTART / CLIP

🧠 Design Philosophy

The central assumption being challenged is:

"Once I win, I'm safe."

THE LAST MOVE turns the moment after victory into the most important
part of the level.

The experience is built around:

False safety
Player observation
Misdirection
Short puzzle sessions
Predictable but deceptive traps
Reaction-worthy failures
Learning through repeated deaths

🎨 UI / UX Direction

The visual direction uses a retro NES-style HUD showing:

WORLD   SCORE   LIVES   TIME
The intended mobile experience is:
Portrait orientation
One-thumb controls
Minimal menus
Large win banners
Small, easy-to-miss final prompts
Retro pixel-art presentation

🛠️ Planned Tech Stack

Component Technology
Game Engine         Godot 4
Game Logic          Tick-based FSM
Level Data          JSON
Capture / Sharing   MP4 Export
Platforms           Web, Android, iOS

📁 Suggested Project Structure

the-last-move/
│
├── assets/
│   ├── audio/
│   ├── fonts/
│   ├── sprites/
│   └── ui/
│
├── data/
│   └── levels/
│
├── scenes/
│   ├── levels/
│   ├── player/
│   ├── traps/
│   └── ui/
│
├── scripts/
│   ├── game/
│   ├── player/
│   ├── traps/
│   └── ui/
│
├── project.godot
├── README.md
└── .gitignore

🗺️ Development Roadmap

WORLD 1 --- Hackathon Build

Playable core experience
10 rooms
Main twist
Chiptune / retro presentation

WORLD 2 --- +6 Weeks

Rage Cam
Grave log

WORLD 3 --- +12 Weeks

Open beta
50 rooms
Trap editor

FINAL BOSS --- Q1 2027

Store launch
iOS
Android
Web

👥 Target Players

THE LAST MOVE is designed especially for:

Troll-game fans aged roughly 16--30
Streamers and short-video creators looking for reaction-friendly
gameplay
Retro puzzle players and commuters looking for quick sessions
The intended growth loop is:

DIE → CLIP → "I'd never fall for that" → INSTALL

👾 Team Binary Brains

Project Status

World 1 / Hackathon Prototype

The initial target is a playable 10-room build demonstrating the core
mechanic: the player reaches the apparent goal and must still survive
one final move.

License

A license has not yet been specified for this project. Until one is
added, please do not assume permission to copy, redistribute, or reuse
the project's code or assets.


The objective is not just to solve the room --- it is to learn when
not to trust the win.
