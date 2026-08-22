import { InputEvent, InputKind, Dir } from '../engine/InputLog';
import { TICK_MS } from '../engine/constants';
import { FlowState, BufferedAction } from './states';
import { Room } from '../sim/RoomLoader';
import { RuleEvaluator } from './RuleEvaluator';
import { TelegraphScheduler } from '../sim/TelegraphScheduler';
import { AudioMix } from '../platform/AudioMix';
import { RageCam } from '../platform/RageCam';
import { TrustMeter } from '../sim/TrustMeter';
import { LevelManager } from '../sim/LevelManager';
import { GraveLogDb, GraveRecord } from '../platform/GraveLogDb';
import { ProfileDb } from '../platform/ProfileDb';
import { Analytics } from '../platform/Analytics';

export interface FlowContext {
  room: Room | null;
  tickInState: number;
  bufferedInputs: BufferedAction[];
  timeTicks: number;
  activeTell: string | null;
  score: number;
  lives: number;
  world: number;
  player: { x: number, y: number };
  touchedExit: { is_real: boolean } | null;
  deathsInRoom: number;
  recentGraves?: GraveRecord[];
  activeRule: string | null;
  lastStepDir: Dir;
  coin: { x: number, y: number } | null;
}

export class GameFlow {
  private static currentState: FlowState = FlowState.BOOT;
  private static ctx: FlowContext = {
    room: null,
    tickInState: 0,
    bufferedInputs: [],
    timeTicks: 3000,
    activeTell: null,
    score: 0,
    lives: 3,
    world: 1,
    player: { x: 0, y: 0 },
    touchedExit: null,
    deathsInRoom: 0,
    activeRule: null,
    lastStepDir: Dir.NONE,
    coin: null
  };
  private static stateDurationTicks = 0;

  static getState() {
    return this.currentState;
  }

  static getContext() {
    return this.ctx;
  }

  static transition(newState: FlowState) {
    // Exit current state logic

    this.currentState = newState;
    this.ctx.tickInState = 0;

    // Enter new state logic
    switch (newState) {
      case FlowState.ROOM_LOAD:
        this.stateDurationTicks = -1;
        RageCam.start();
        break;
      case FlowState.SOLVE:
        this.stateDurationTicks = -1;
        break;
      case FlowState.EXIT_TOUCHED:
        this.stateDurationTicks = Math.floor(200 / TICK_MS);
        break;
      case FlowState.WIN_BANNER:
        this.stateDurationTicks = Math.floor(1200 / TICK_MS);
        this.ctx.bufferedInputs = []; // Clear buffer
        AudioMix.playFanfare();
        break;
      case FlowState.LAST_MOVE_WINDOW: {
        let baseMs = 3000;
        if (this.ctx.room) {
          baseMs = this.ctx.room.last_move.window_ms;
        }
        
        const score = TrustMeter.getScore();
        let mult = 1.5 - (score / 100);
        let finalMs = baseMs * mult;
        this.stateDurationTicks = Math.floor(finalMs / TICK_MS);

        const paranoia = TrustMeter.getParanoia();
        if (paranoia > 80 && Math.random() < 0.1) {
          this.ctx.activeRule = null;
        }
        break;
      }
      case FlowState.RESOLVE:
        this.stateDurationTicks = 0; // Instant
        break;
      case FlowState.DEATH:
        this.stateDurationTicks = Math.floor(6000 / TICK_MS);
        RageCam.stopAndShow();
        break;
      case FlowState.SURVIVE:
        this.stateDurationTicks = Math.floor(2000 / TICK_MS);
        break;
      case FlowState.SCORE_TALLY:
        this.stateDurationTicks = Math.floor(1000 / TICK_MS);
        break;
      case FlowState.ROOM_RELOAD:
        this.stateDurationTicks = 0;
        break;
      default:
        this.stateDurationTicks = -1;
    }
  }

  static setRoom(room: Room) {
    this.ctx.room = room;
    this.ctx.timeTicks = Math.floor(60000 / TICK_MS); // 60s
    this.ctx.player = { x: room.player_start.x, y: room.player_start.y };
    this.ctx.touchedExit = null;
    this.ctx.deathsInRoom = 0;
    this.ctx.activeRule = null;
    this.updateActiveRule();
    
    if (this.ctx.room) {
      Analytics.trackLevelStart(this.ctx.room.id);
    }
  }

  private static updateActiveRule() {
    if (!this.ctx.room) {
      this.ctx.activeRule = null;
      return;
    }
    const baseRule = this.ctx.room.last_move.rule;
    const mutations = this.ctx.room.last_move.mutations;
    if (mutations && mutations.length > 0) {
      const allRules = [baseRule, ...mutations];
      const index = this.ctx.deathsInRoom % allRules.length;
      this.ctx.activeRule = allRules[index];
    } else {
      this.ctx.activeRule = baseRule;
    }
  }

  static tick(inputs: InputEvent[]) {
    if (this.currentState === FlowState.ROOM_LOAD) {
      if (LevelManager.isReady()) {
        const room = LevelManager.getRoom();
        if (room) {
          this.setRoom(room);
          this.transition(FlowState.SOLVE);
        }
      }
      return;
    }

    if (this.currentState === FlowState.GRAVEYARD) {
       for (const input of inputs) {
          if (input.kind === InputKind.TAP || input.kind === InputKind.CONTINUE) {
             // Restart game
             this.ctx.lives = 3;
             this.ctx.score = 0;
             this.ctx.world = 1;
             this.ctx.deathsInRoom = 0;
             LevelManager.resetSequence();
             LevelManager.loadNextRoom();
             this.transition(FlowState.ROOM_LOAD);
             return;
          }
       }
       return; // Block other ticks
    }

    // Process input depending on state
    if (this.currentState === FlowState.SOLVE) {
      this.ctx.timeTicks--;
      let moved = false;
      for (const input of inputs) {
        if (input.kind === InputKind.MOVE && !moved) {
          let dx = 0, dy = 0;
          if (input.dir === Dir.UP) dy = -1;
          if (input.dir === Dir.DOWN) dy = 1;
          if (input.dir === Dir.LEFT) dx = -1;
          if (input.dir === Dir.RIGHT) dx = 1;

          if (dx !== 0 || dy !== 0) {
            const nx = this.ctx.player.x + dx;
            const ny = this.ctx.player.y + dy;

            if (this.ctx.room && nx >= 0 && nx < this.ctx.room.grid.w && ny >= 0 && ny < this.ctx.room.grid.h) {
              const hitWall = this.ctx.room.walls.some(w => w.x === nx && w.y === ny);
              if (!hitWall) {
                this.ctx.player.x = nx;
                this.ctx.player.y = ny;
                this.ctx.lastStepDir = input.dir;
                moved = true;
              }
            }
          }
        }
      }

      if (moved && this.ctx.room) {
        const hitExit = this.ctx.room.exits.find(e => e.x === this.ctx.player.x && e.y === this.ctx.player.y);
        if (hitExit) {
          this.ctx.touchedExit = hitExit;
          this.transition(FlowState.EXIT_TOUCHED);
          return;
        }
      }
    }
    else if (this.currentState === FlowState.WIN_BANNER) {
      // Buffer inputs
      for (const input of inputs) {
        this.ctx.bufferedInputs.push({ atTick: this.ctx.tickInState, ev: input });
      }
    }
    else if (this.currentState === FlowState.LAST_MOVE_WINDOW) {
      // Also buffer inputs into the same array (or handle immediately)
      for (const input of inputs) {
        this.ctx.bufferedInputs.push({ atTick: this.ctx.tickInState, ev: input });
      }
    }

    // Evaluate active tell
    if (this.currentState === FlowState.WIN_BANNER || this.currentState === FlowState.LAST_MOVE_WINDOW) {
      const newTell = TelegraphScheduler.getActiveTell(
        this.ctx.room,
        this.ctx.tickInState,
        this.currentState === FlowState.WIN_BANNER,
        this.currentState === FlowState.LAST_MOVE_WINDOW
      );

      // Trigger whisper on the exact tick the tell activates
      if (newTell && this.ctx.activeTell !== newTell) {
        AudioMix.playTellWhisper();
      }
      this.ctx.activeTell = newTell;
    } else {
      this.ctx.activeTell = null;
    }

    // Advance state timer
    this.ctx.tickInState++;

    if (this.stateDurationTicks >= 0 && this.ctx.tickInState >= this.stateDurationTicks) {
      this.advanceState();
    }
  }

  private static advanceState() {
    switch (this.currentState) {
      case FlowState.BOOT:
        LevelManager.loadNextRoom();
        this.transition(FlowState.ROOM_LOAD);
        break;
      case FlowState.ROOM_LOAD:
        this.transition(FlowState.SOLVE);
        break;
      case FlowState.EXIT_TOUCHED:
        this.transition(FlowState.WIN_BANNER);
        break;
      case FlowState.WIN_BANNER:
        this.transition(FlowState.LAST_MOVE_WINDOW);
        break;
      case FlowState.LAST_MOVE_WINDOW:
        this.transition(FlowState.RESOLVE);
        break;
      case FlowState.RESOLVE: {
        const survived = RuleEvaluator.evaluate(
          this.ctx.activeRule || 'DO_NOT_MOVE',
          this.ctx
        );
        
        const firstInput = this.ctx.bufferedInputs[0];
        const t_relax = firstInput ? firstInput.atTick * TICK_MS : 3000;

        // Win state visual setup
        this.ctx.timeTicks = this.ctx.room?.last_move.window_ms || 3000;
        this.ctx.timeTicks = Math.floor(this.ctx.timeTicks / TICK_MS);
        AudioMix.playFanfare();
        
        if (this.ctx.activeRule === 'DO_NOT_COLLECT') {
          this.ctx.coin = { x: this.ctx.player.x, y: this.ctx.player.y - 1 };
        } else {
          this.ctx.coin = null;
        }

        if (!survived) {
          this.ctx.deathsInRoom++;
          this.ctx.lives = Math.max(0, this.ctx.lives - 1);
          ProfileDb.addDeath();
          Analytics.trackTrapFailed(this.ctx.room?.id || '', this.ctx.activeRule || '', t_relax);
          
          if (this.ctx.room) {
             GraveLogDb.addGrave({
               roomId: this.ctx.room.id,
               rule: this.ctx.activeRule || 'UNKNOWN',
               paranoia: TrustMeter.getParanoia(),
               timestamp: Date.now()
             });
          }
        }

        TrustMeter.evaluate(survived, this.ctx.bufferedInputs);

        this.transition(survived ? FlowState.SURVIVE : FlowState.DEATH);
        break;
      }
      case FlowState.DEATH:
        if (this.ctx.lives <= 0) {
           this.transition(FlowState.GRAVEYARD);
        } else {
           this.transition(FlowState.ROOM_RELOAD);
        }
        break;
      case FlowState.SURVIVE:
        this.transition(FlowState.SCORE_TALLY);
        break;
      case FlowState.SCORE_TALLY: {
        const base = 1000;
        const timeBonus = this.ctx.timeTicks * 10;
        const rule = this.ctx.activeRule;
        const survivalBonus = (rule === 'DO_NOT_MOVE' || rule === 'DO_NOT_TOUCH') ? 2000 : 0;
        const total = base + timeBonus + survivalBonus;
        
        this.ctx.score += total;
        ProfileDb.addScore(total);
        Analytics.trackTrapSurvived(this.ctx.room?.id || '', rule || '');
        
        LevelManager.advance();
        ProfileDb.updateMaxRoom(LevelManager.getCurrentIndex());
        LevelManager.loadNextRoom();
        this.transition(FlowState.ROOM_LOAD);
        break;
      }
      case FlowState.ROOM_RELOAD:
        LevelManager.reloadCurrentRoom();
        this.updateActiveRule();
        this.transition(FlowState.ROOM_LOAD);
        break;
      case FlowState.GRAVEYARD:
        this.stateDurationTicks = -1; // wait for click
        GraveLogDb.getRecentGraves(3).then(graves => {
           this.ctx.recentGraves = graves;
        });
        break;
    }
  }
}
