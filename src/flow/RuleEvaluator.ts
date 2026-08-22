import { InputKind, Dir } from '../engine/InputLog';
import { FlowContext } from './GameFlow';

export class RuleEvaluator {
  static evaluate(rule: string, ctx: FlowContext): boolean {
    const buffer = ctx.bufferedInputs;
    
    switch (rule) {
      case 'DO_NOT_MOVE':
        return !buffer.some(a => a.ev.kind === InputKind.MOVE);
      
      case 'DO_NOT_TOUCH':
      case 'LET_TIMER_HIT_ZERO': // Functionally identical to DO_NOT_TOUCH for evaluation
        return !buffer.some(a => a.ev.kind === InputKind.MOVE || a.ev.kind === InputKind.TAP || a.ev.kind === InputKind.CONTINUE);
      
      case 'DO_NOT_PRESS_CONTINUE':
        return !buffer.some(a => a.ev.kind === InputKind.CONTINUE);
      
      case 'PRESS_CONTINUE_FAST':
        return buffer.some(a => a.ev.kind === InputKind.CONTINUE);
      
      case 'MOVE_TO_TRUE_EXIT':
        return ctx.touchedExit ? ctx.touchedExit.is_real : false;
      
      case 'MOVE_EXACTLY_ONCE': {
        const moves = buffer.filter(a => a.ev.kind === InputKind.MOVE);
        return moves.length === 1;
      }
      
      case 'RETRACE_LAST_STEP': {
        const firstMove = buffer.find(a => a.ev.kind === InputKind.MOVE);
        if (!firstMove) return false;
        
        // Match opposite direction
        const opp: Record<number, number> = {
          [Dir.UP]: Dir.DOWN,
          [Dir.DOWN]: Dir.UP,
          [Dir.LEFT]: Dir.RIGHT,
          [Dir.RIGHT]: Dir.LEFT
        };
        return firstMove.ev.dir === opp[ctx.lastStepDir];
      }
      
      case 'DO_NOT_COLLECT': {
        if (!ctx.coin) return true;
        // Collect if player moved onto the coin tile
        return !(ctx.player.x === ctx.coin.x && ctx.player.y === ctx.coin.y);
      }
      
      case 'MIRROR_THE_TELL': {
        const firstMove = buffer.find(a => a.ev.kind === InputKind.MOVE);
        if (!firstMove || !ctx.activeTell) return false;
        
        if (ctx.activeTell === 'ARROW_UP') return firstMove.ev.dir === Dir.UP;
        if (ctx.activeTell === 'ARROW_DOWN') return firstMove.ev.dir === Dir.DOWN;
        if (ctx.activeTell === 'ARROW_LEFT') return firstMove.ev.dir === Dir.LEFT;
        if (ctx.activeTell === 'ARROW_RIGHT') return firstMove.ev.dir === Dir.RIGHT;
        
        return false;
      }

      default:
        return false;
    }
  }
}
