import { InputEvent, InputKind, Dir } from '../engine/InputLog';
import { AudioMix } from './AudioMix';

export class Input {
  private static pendingEvents: InputEvent[] = [];
  
  static init() {
    window.addEventListener('keydown', (e) => {
      AudioMix.unlock();
      let dir = Dir.NONE;
      if (e.key === 'ArrowUp' || e.key === 'w') dir = Dir.UP;
      if (e.key === 'ArrowDown' || e.key === 's') dir = Dir.DOWN;
      if (e.key === 'ArrowLeft' || e.key === 'a') dir = Dir.LEFT;
      if (e.key === 'ArrowRight' || e.key === 'd') dir = Dir.RIGHT;
      
      if (dir !== Dir.NONE) {
        this.pendingEvents.push({ kind: InputKind.MOVE, dir });
      }
      
      if (e.key === 'Enter' || e.key === ' ') {
        this.pendingEvents.push({ kind: InputKind.CONTINUE, dir: Dir.NONE });
      }
    });

    let startX = 0;
    let startY = 0;
    const DEADZONE = 24;

    window.addEventListener('pointerdown', (e) => {
      AudioMix.unlock();
      startX = e.clientX;
      startY = e.clientY;
      
      const isBottomCenter = e.clientY > window.innerHeight - 80;
      if (isBottomCenter) {
        Input.pendingEvents.push({ kind: InputKind.CONTINUE, dir: Dir.NONE });
      } else {
        Input.pendingEvents.push({ kind: InputKind.TAP, dir: Dir.NONE });
      }
    });

    window.addEventListener('pointerup', (e) => {
      const dx = e.clientX - startX;
      const dy = e.clientY - startY;
      
      if (Math.abs(dx) > DEADZONE || Math.abs(dy) > DEADZONE) {
        let dir = Dir.NONE;
        if (Math.abs(dx) > Math.abs(dy)) {
          dir = dx > 0 ? Dir.RIGHT : Dir.LEFT;
        } else {
          dir = dy > 0 ? Dir.DOWN : Dir.UP;
        }
        this.pendingEvents.push({ kind: InputKind.MOVE, dir });
      } else {
        this.pendingEvents.push({ kind: InputKind.TAP, dir: Dir.NONE });
      }
    });
  }

  static drainForTick(_tick: number): InputEvent[] {
    const events = [...this.pendingEvents];
    this.pendingEvents = [];
    return events;
  }
}
