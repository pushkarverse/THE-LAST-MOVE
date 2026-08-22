# THE LAST MOVE — Design Mechanism

## 1. Core Concept

The Last Move is a short-form puzzle/troll game built around one psychological assumption:

> "Once I win, I'm safe."

Reaching the exit does not actually end the level.

Instead, reaching the exit begins the most important part of the level:
THE LAST MOVE.

Every trap is telegraphed.
Nothing should be purely random.

---

## 2. Core Gameplay Loop

Every level follows four major stages:

### Stage 1 — SOLVE
The player solves a deliberately simple puzzle and reaches the exit.

The normal puzzle should be relatively easy because it is not the main challenge.

PLAYER
  ↓
SOLVE ROOM
  ↓
REACH EXIT

### Stage 2 — COMPLETE
The game displays a convincing Level Complete sequence.

Possible feedback includes:
- victory sound
- confetti
- score animation
- Level Complete banner
- Continue button
- Screen transition effects

The purpose is to create a moment of false safety.

REACH EXIT
    ↓
LEVEL COMPLETE
    ↓
PLAYER RELAXES

### Stage 3 — LAST MOVE
After the apparent victory, one final situation occurs.

The player may need to:

MOVE_LEFT
MOVE_RIGHT
JUMP
WAIT
INTERACT
DO_NOT_TOUCH

The correct action depends on the room.
The player must observe the environment before acting.

### Stage 4 — SURVIVE or DIE

If the player reads the situation correctly:

LAST MOVE
    ↓
CORRECT ACTION
    ↓
SURVIVE
    ↓
NEXT ROOM

If the player reacts incorrectly:

LAST MOVE
    ↓
WRONG ACTION
    ↓
DEATH
    ↓
RESTART

## 3. Game State System

The game should move through clearly defined states.

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
├── SURVIVED → NEXT_LEVEL
└── DEAD → RESTART

Possible TypeScript representation:

type GameState =
  | "START"
  | "PLAYING"
  | "EXIT_REACHED"
  | "FAKE_COMPLETE"
  | "LAST_MOVE"
  | "SURVIVED"
  | "DEAD"
  | "PAUSED";

The important rule is:

EXIT_REACHED ≠ LEVEL_FINISHED

Instead:

EXIT_REACHED
     ↓
FAKE_COMPLETE
     ↓
LAST_MOVE
     ↓ 
TRUE COMPLETION

---

## 4. The Exit Mechanism

The exit should initially behave like a normal game exit.

When the player reaches it:

1. Normal controls may temporarily stop.
2. "LEVEL COMPLETE" appears.
3. Victory effects play.
4. The player assumes the level is finished.
5. A hidden post-win sequence begins.
6. The game presents the Last Move.

Therefore:

EXIT ≠ LEVEL FINISHED

Instead:

EXIT → LAST MOVE PHASE
The exit activates the final puzzle.

---

## 5. The Last Move Mechanism

Each level contains a final trap.

Possible actions:

MOVE_LEFT
MOVE_RIGHT
JUMP
WAIT
INTERACT
DO_NOT_TOUCH

Examples:

Falling Block

The player reaches the exit.

LEVEL COMPLETE

A ceiling block begins shaking.

Correct action:

MOVE_LEFT

Wrong action:

STAY UNDER THE BLOCK

Fake Continue Button

The player reaches the exit.

LEVEL COMPLETE

CONTINUE ▶

The button is part of the trap.

Correct action:

DO_NOT_TOUCH

Wrong action:

PRESS CONTINUE

The player must determine the correct final action.

Example:

Level 1:

Player reaches the exit.

"LEVEL COMPLETE"

A ceiling block begins shaking.

Correct action:
MOVE LEFT.

Wrong action:
Remain underneath it.

---

Another level:

"LEVEL COMPLETE"

A suspicious Continue button appears.

Correct action:
DO NOTHING.

Wrong action:
Press Continue immediately.

---

Another level:

"LEVEL COMPLETE"

An enemy charges toward the player.

Correct action:
WAIT.

The enemy falls into a hidden pit.

Wrong action:
Jump.

---

## 6. Forced First Death — Room 1-1

Room 1-1 is a special tutorial exception.

Its purpose is to guarantee that every first-time player immediately understands the central mechanic.

Without this tutorial, a player or hackathon judge could accidentally survive the first trap and misunderstand the entire concept of the game.

First Attempt

The player reaches the exit.

LEVEL COMPLETE

Immediately after the fake victory, a ceiling block falls.

The player is killed before they can meaningfully react.

LEVEL COMPLETE
      ↓
CEILING BLOCK FALLS
      ↓
PLAYER DIES

The game then displays:

THE LEVEL
WASN'T OVER.

followed by:

THE RULE WAS:

DO NOT MOVE.

The room then restarts.

Important Tutorial Rules

The first death is a teaching event, not a normal failure.

Therefore, it must:

- Not remove a life
- Not reduce score
- Not affect the Trust Meter
- Not count toward player death statistics
- Not trigger Rage Cam
- Not affect leaderboard statistics

Example configuration:

{
  "tutorial": {
    "forcedFailure": true,
    "consumeLife": false,
    "countDeath": false,
    "affectTrustMeter": false,
    "generateClip": false,
    "showRuleAfterDeath": true
  }
}
Second Attempt

After restarting Room 1-1, the room behaves according to normal fairness rules.

The ceiling block should now be properly telegraphed.

For example:

- Ceiling shaking
- Dust particles
- Warning sound
- Shadow beneath the block
- Short delay before falling

The player can now survive.

## Forced Death Rule:

Room 1-1 is the only intentionally unavoidable death in the game.

Every normal room after it must be survivable on the first attempt through observation.

## 7. Telegraphing Rules

The game must be deceptive but fair.

Every trap needs at least one clue.

Possible telegraph includes:

- animation
- sound
- environmental movement
- suspicious UI
- shadows
- changing text
- enemy behaviour
- object positioning
- timing
- previous-level knowledge

Important rule:

NO COMPLETELY RANDOM DEATHS.

Players should be able to think:

"I should have noticed that."

instead of:

"There was no way I could know."

---

## 8. Player Action Definitions

The game should use a limited set of Last Move actions.

type LastMoveAction =
  | "MOVE_LEFT"
  | "MOVE_RIGHT"
  | "JUMP"
  | "WAIT"
  | "INTERACT"
  | "DO_NOT_TOUCH";

Keeping the actions limited makes level design easier to understand and maintain.

## 9. WAIT vs DO_NOT_TOUCH

These two actions must remain separate.

WAIT

WAIT means:

Do not act immediately, but interaction may be required later.

Example:

LEVEL COMPLETE
      ↓
ENEMY CHARGES
      ↓
WAIT 2 SECONDS
      ↓
ENEMY FALLS
      ↓
MOVE

Example configuration:

{
  "action": "WAIT",
  "duration": 2000,
  "then": "MOVE_RIGHT"
}
DO_NOT_TOUCH

DO_NOT_TOUCH means:

Do not perform any gameplay interaction until the Last Move sequence ends.

Example:

LEVEL COMPLETE
      ↓
FLOOR SHAKES
      ↓
PLAYER DOES NOTHING
      ↓
3
2
1
      ↓
FLOOR STABILIZES
      ↓
SURVIVED

Example:

{
  "action": "DO_NOT_TOUCH",
  "duration": 3000
}
10. Mobile DO_NOT_TOUCH Protection

DO_NOT_TOUCH must only detect intentional interaction inside the game.

It must not punish the player for operating-system behaviour.

The rule should therefore mean:

No gameplay interaction inside the active game viewport.

nputs That SHOULD Count

These should count as gameplay input:

Tap inside active game area
Swipe inside active game area

Movement control pressed
Jump control pressed
Interact control pressed
Game button pressed
Inputs That SHOULD NOT Count

The game should ignore:

Notification interaction
Screen-edge gestures
Browser controls
Operating-system gestures
Accidental multi-touch
Pointer cancellation
Device UI interaction

If the game loses focus:

PP LOSES FOCUS
      ↓
PAUSE GAME

The player should not automatically die.

## 11. Input Zone

Mobile input should be restricted to the actual gameplay interface.

Example:

┌─────────────────────────┐
│ WORLD 1-2   ♥♥♥    042 │
│                         │
│                         │
│       GAME WORLD        │
│                         │
│         PLAYER          │
│                         │
│                         │
├─────────────────────────┤
│      CONTROL ZONE       │
│                         │
│   ◀       ●        ▶   │
└─────────────────────────┘

Only interactions within valid game regions should count as gameplay actions.



## 12. False Flag Mechanic

Some rooms should appear to provide an obvious solution.
That solution is intentionally misleading.

Example:

VISIBLE SOLUTION
      ↓
LOOKS CORRECT
      ↓
ENVIRONMENT PROVIDES CLUE
      ↓
PLAYER QUESTIONS IT
      ↓
REAL SOLUTION

The goal is to teach the player:

Do not automatically trust the obvious answer.
---

## 13. Rule Mutation

The Last Move must not always use the same rule.

Otherwise players will discover one universal strategy.

Bad progression:

Room 1 → Don't move
Room 2 → Don't move
Room 3 → Don't move
Room 4 → Don't move

The player would simply stop touching the screen after every victory.

Instead:

Room 1 → DO_NOT_TOUCH
Room 2 → MOVE_LEFT
Room 3 → WAIT
Room 4 → INTERACT
Room 5 → JUMP
Room 6 → MOVE_RIGHT
Room 7 → DO_NOT_TOUCH

The player must observe each room individually.

---

## 14. Trust Meter

The game can internally track how quickly the player relaxes after reaching the exit.

Possible measurements:

- reactionTime
- continueClickSpeed
- movementAfterVictory
- hesitationTime
- repeatedBehaviour
- numberOfDeaths

Possible TypeScript structure:

interface PlayerBehaviour {
  averageReactionTime: number;
  immediateMovementRate: number;
  hesitationRate: number;
  deaths: number;
}

The Trust Meter may later influence difficulty.
Example:

trustScore = reactionTime + repeatedBehaviour

The game can use this information to alter future traps.

High trust:
Player reacts quickly after winning.

→ More deceptive post-win traps.

Low trust:
Player is extremely cautious.

→ Levels designed to punish excessive hesitation.

---

## 15. Difficulty Progression

Difficulty should not mainly come from harder controls.

Difficulty should come from:

OBSERVATION
+
EXPECTATION
+
MISDIRECTION
+
TIMING

It should not primarily come from increasingly difficult movement controls.
----------------
Early Rooms
----------------
Use obvious telegraphs.

Example:

LOUD SOUND
SHAKING OBJECT
CLEAR SHADOW

----------------
Middle Rooms
----------------
Use subtler clues.

Example:

SMALL UI CHANGE
SLIGHT ANIMATION
DELAYED SOUND

----------------
Later Rooms
----------------
Use conflicting information.

Example:

UI SAYS MOVE
ENVIRONMENT SAYS WAIT

The player must decide which information is trustworthy.

---

## 15. Level Data

Levels should ideally be data-driven.

Example structure:

Level
- id
- name
- world
- timeLimit
- exitPosition
- trapType
- telegraph
- correctAction
- lastMoveDelay
- difficulty
- scoreReward
 -tutorialSettings
 
Example:

{
  "id": "world-1-level-1", 
  "name": "Don't Celebrate Yet", 
  "world": 1, 
  "timeLimit": 60, 
  
  "exit": 
   { 
     "x": 850, 
     "y": 420 
   }, 
   
   "lastMove": 
    { "delay": 2000, 
    "correctAction": "MOVE_LEFT", 
  "trap": "FALLING_BLOCK", 
  "telegraph": "CEILING_SHAKE" 
    }, 
    "rewards": 
    { 
       "completionScore": 1000, 
       "survivalBonus": 500 
    }
}

A data-driven system allows additional levels to be created without rewriting the entire game engine.

---

## 17. Player Controls

The game should remain simple.

Possible controls:

Desktop:
- A / Left Arrow → Move Left 
- D / Right Arrow → Move Right
- Space → Jump
- E → Interact
- Escape → Pause

Mobile:
- Tap 
- Swipe
- Virtual Left 
- Virtual Right 
- Action Button

Controls should remain intentionally simple because the challenge comes from decision-making rather than complicated movement.

---

## 18. UI Behaviour

Main HUD:

WORLD
SCORE
LIVES
TIME

Victory sequence:

LEVEL COMPLETE

followed subtly by:

ONE FINAL MOVE

The visual hierarchy should intentionally make:

LEVEL COMPLETE

very obvious,

while:

ONE FINAL MOVE

is quieter and easier to overlook.

---

## 14. Death System

Death should be:

- fast
- understandable
- slightly surprising
- funny
- replayable

After death:

DEATH
↓
SHORT REACTION
↓
RESTART

The player should be able to restart almost immediately.

Avoid long loading screens.

---

## 15. Lives System

Initial concept:

♥ ♥ ♥

A failed Last Move removes one life.

Example:

♥ ♥ ♥
↓
♥ ♥ ♡
↓
♥ ♡ ♡

The final implementation can decide whether lives are:

- per level
- per world
- cosmetic
- tied to score

---

## 16. Scoring

Possible score components:

Base puzzle completion
+
Speed bonus
+
First-attempt survival bonus
+
Remaining lives bonus
+
Last Move bonus

Deaths can reduce the final score without preventing progression.

---

## 17. Timer

Each room should be short.

Target:

Under 60 seconds per room.

The timer creates urgency while keeping the game suitable for:

- quick sessions
- streaming
- short-form content
- repeated attempts

---

## 18. Rage Cam / Clip System

When the player dies during the Last Move:

Death Event
↓
Capture recent gameplay
↓
Generate short clip
↓
Optional Share

For the first prototype this feature does NOT need to be fully implemented.

It can initially be represented by:

"CLIP THAT DEATH"

or a simple replay mechanism.

---

## 19. Level Progression

Example:

WORLD 1

1-1 → Introduction
1-2 → Move after winning
1-3 → Don't move
1-4 → Fake Continue button
1-5 → Delayed trap
1-6 → False Flag
1-7 → Rule Mutation
1-8 → Multi-stage Last Move
1-BOSS → Player's assumptions are tested together

---

## 20. Design Principles

Every level should follow these rules:

1. Easy to understand.
2. Fast to retry.
3. The normal puzzle is intentionally simple.
4. The real challenge happens after apparent victory.
5. Every trap has a clue.
6. Nothing important is purely random.
7. Do not repeat the same Last Move continuously.
8. Failure should teach the player something.
9. Death should feel surprising enough to be memorable.
10. The player should distrust the phrase "LEVEL COMPLETE."

---

## 21. Technical Mechanism

Current implementation:

Frontend / Game Runtime:
Vite + TypeScript

Architecture:

Input System
↓
Player Controller
↓
Level Manager
↓
Game State Manager
↓
Exit Detection
↓
Fake Victory Controller
↓
Last Move Controller
↓
Trap System
↓
Result
├── Survival
└── Death

Recommended game modules:

src/
├── game/
│   ├── Game.ts
│   ├── GameState.ts
│   ├── GameLoop.ts
│
├── player/
│   ├── Player.ts
│   └── PlayerController.ts
│
├── levels/
│   ├── LevelManager.ts
│   └── levelData.ts
│
├── traps/
│   ├── Trap.ts
│   └── TrapManager.ts
│
├── systems/
│   ├── TrustMeter.ts
│   ├── ScoreSystem.ts
│   ├── LivesSystem.ts
│   └── TimerSystem.ts
│
└── ui/
    ├── HUD.ts
    ├── WinScreen.ts
    └── DeathScreen.ts

---

## 22. Golden Rule

The central rule of The Last Move is:

THE LEVEL DOES NOT END WHEN THE PLAYER WINS.

The apparent victory is part of the puzzle.

The true victory occurs only after the player survives:

THE LAST MOVE.
