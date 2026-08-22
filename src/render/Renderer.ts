import { FlowState } from '../flow/states';
import { GameFlow } from '../flow/GameFlow';
import { TrustMeter } from '../sim/TrustMeter';

export class Renderer {
  private static canvas: HTMLCanvasElement;
  private static ctx: CanvasRenderingContext2D;
  private static width = 180;
  private static height = 320;

  static init(canvasId: string) {
    this.canvas = document.getElementById(canvasId) as HTMLCanvasElement;
    this.ctx = this.canvas.getContext('2d') as CanvasRenderingContext2D;

    // Nearest neighbor
    this.ctx.imageSmoothingEnabled = false;

    this.resize();
    window.addEventListener('resize', () => this.resize());
  }

  private static resize() {
    const scale = Math.max(1, Math.floor(Math.min(window.innerWidth / this.width, window.innerHeight / this.height)));

    this.canvas.width = this.width;
    this.canvas.height = this.height;

    this.canvas.style.width = `${this.width * scale}px`;
    this.canvas.style.height = `${this.height * scale}px`;
  }

  static draw(state: FlowState, _alpha: number) {
    const { room, timeTicks, activeTell, score, lives, world } = GameFlow.getContext();

    // Clear
    this.ctx.fillStyle = '#111';
    this.ctx.fillRect(0, 0, this.width, this.height);

    // Draw HUD
    this.ctx.fillStyle = '#000';
    this.ctx.fillRect(0, 0, this.width, 16);
    this.ctx.fillStyle = '#fff';
    this.ctx.font = '8px monospace';

    const timeStr = Math.max(0, Math.floor(timeTicks / 60)).toString().padStart(3, '0');
    const scoreStr = score.toString().padStart(6, '0');
    const livesStr = '♥'.repeat(lives);

    this.ctx.textAlign = 'left';
    this.ctx.fillText(`W${world} ${scoreStr} P:${TrustMeter.getParanoia()}%`, 4, 11);
    this.ctx.textAlign = 'right';
    this.ctx.fillText(`${livesStr} T:${timeStr}`, this.width - 4, 11);

    // Basic state text (shifted down)
    this.ctx.textAlign = 'center';
    this.ctx.fillStyle = '#666';
    this.ctx.fillText(`State: ${FlowState[state]}`, this.width / 2, 30);

    if (room) {
      const TILE_SIZE = 16;
      const gridW = room.grid.w * TILE_SIZE;
      const gridH = room.grid.h * TILE_SIZE;
      const offsetX = (this.width - gridW) / 2;
      const offsetY = (this.height - gridH) / 2 + 10;

      // Draw floor
      this.ctx.fillStyle = '#222';
      this.ctx.fillRect(offsetX, offsetY, gridW, gridH);

      // Draw walls
      this.ctx.fillStyle = '#555';
      for (const w of room.walls) {
        this.ctx.fillRect(offsetX + w.x * TILE_SIZE, offsetY + w.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
      }

      // Draw exits
      for (const e of room.exits) {
        if (e.has_shadow) {
          // The "decoy" tell - 2px subtle shadow
          this.ctx.fillStyle = '#000';
          this.ctx.fillRect(offsetX + e.x * TILE_SIZE + 2, offsetY + e.y * TILE_SIZE + 2, TILE_SIZE, TILE_SIZE);
        }
        this.ctx.fillStyle = '#FFD700';
        this.ctx.fillRect(offsetX + e.x * TILE_SIZE, offsetY + e.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);

        // Ghost Outline Hint on Retry
        if (e.is_real && GameFlow.getContext().deathsInRoom > 0) {
          const alpha = 0.3 + 0.2 * Math.sin(performance.now() / 200);
          this.ctx.strokeStyle = `rgba(0, 255, 255, ${alpha})`;
          this.ctx.lineWidth = 2;
          this.ctx.strokeRect(offsetX + e.x * TILE_SIZE - 2, offsetY + e.y * TILE_SIZE - 2, TILE_SIZE + 4, TILE_SIZE + 4);
        }
      }

      // Draw player
      const px = GameFlow.getContext().player.x;
      const py = GameFlow.getContext().player.y;
      this.ctx.fillStyle = '#FFF';
      this.ctx.fillRect(offsetX + px * TILE_SIZE + 2, offsetY + py * TILE_SIZE + 2, TILE_SIZE - 4, TILE_SIZE - 4);
    }

    if (state === FlowState.WIN_BANNER) {
      this.ctx.fillStyle = '#FFD700';
      this.ctx.fillText('LEVEL COMPLETE!', this.width / 2, 20); // Moved up to not overlap grid
      this.ctx.fillStyle = '#fff';
      this.ctx.fillText('(+6dB Fanfare)', this.width / 2, 40);
    }
    else if (state === FlowState.LAST_MOVE_WINDOW) {
      this.ctx.fillStyle = '#AAA';
      this.ctx.fillText('one final move...', this.width / 2, 20);
    }

    // Draw continue button for both win banner and last move window
    if (state === FlowState.WIN_BANNER || state === FlowState.LAST_MOVE_WINDOW) {
      if (Math.floor(performance.now() / 500) % 2 === 0 || activeTell === 'GLOW_CONTINUE') {
        this.ctx.fillStyle = activeTell === 'GLOW_CONTINUE' ? 'red' : '#444';
        this.ctx.fillRect(this.width / 2 - 40, this.height - 40, 80, 20);
        this.ctx.fillStyle = '#FFF';
        this.ctx.fillText('[ CONTINUE ]', this.width / 2, this.height - 26);
      }
    }
    else if (state === FlowState.DEATH) {
      this.ctx.fillStyle = '#8B0000';
      this.ctx.fillRect(0, 16, this.width, this.height - 16);

      this.ctx.fillStyle = '#FFF';
      this.ctx.font = '12px monospace';
      this.ctx.fillText('YOU DIED', this.width / 2, this.height / 2 - 20);

      this.ctx.font = '10px monospace';
      this.ctx.fillStyle = '#FFAAAA';
      this.ctx.fillText('RULE BROKEN:', this.width / 2, this.height / 2 + 10);

      this.ctx.fillStyle = '#FFF';
      this.ctx.fillText(`${GameFlow.getContext().activeRule || 'UNKNOWN'}`, this.width / 2, this.height / 2 + 25);

      const gctx = GameFlow.getContext();
      this.ctx.font = '8px monospace';
      this.ctx.fillStyle = '#AAA';
      this.ctx.fillText(`ROOM: ${gctx.room?.id || '???'} | DEATH #${gctx.deathsInRoom}`, this.width / 2, this.height / 2 + 45);

      this.ctx.font = '7px monospace';
      this.ctx.fillStyle = '#AAA';
      this.ctx.fillText('* NOTHING IS RANDOM. WATCH CAREFULLY.', this.width / 2, this.height - 10);
    }
    else if (state === FlowState.SURVIVE) {
      this.ctx.fillStyle = 'green';
      this.ctx.fillText('YOU SURVIVED!', this.width / 2, 20);
    }

    if (activeTell === 'TILE_FLICKER') {
      if (Math.floor(performance.now() / 100) % 2 === 0) {
        this.ctx.fillStyle = 'red';
        this.ctx.fillText('[TELL: FLOOR FLICKERS]', this.width / 2, this.height / 2 + 40);
        this.ctx.strokeStyle = 'red';
        this.ctx.lineWidth = 2;
        this.ctx.strokeRect(this.width / 2 - 20, this.height / 2 - 20, 40, 40);
      }
    }

    if (state === FlowState.GRAVEYARD) {
      this.ctx.fillStyle = '#1a2b22'; // Dark mossy green
      this.ctx.fillRect(0, 0, this.width, this.height);
      
      this.ctx.fillStyle = 'white';
      this.ctx.textAlign = 'center';
      this.ctx.font = '14px monospace';
      this.ctx.fillText('GRAVEYARD', this.width / 2, 40);
      
      this.ctx.font = '8px monospace';
      const graves = GameFlow.getContext().recentGraves || [];
      
      let y = 80;
      for (const grave of graves) {
         this.ctx.fillStyle = '#7a8c82'; // tombstone grey
         this.ctx.fillRect(20, y - 10, this.width - 40, 40);
         this.ctx.fillStyle = 'black';
         this.ctx.fillText(`R.I.P. W${grave.roomId}`, this.width / 2, y + 2);
         this.ctx.fillText(`Failed: ${grave.rule}`, this.width / 2, y + 14);
         this.ctx.fillText(`Paranoia: ${grave.paranoia}%`, this.width / 2, y + 26);
         y += 60;
      }
      
      if (Math.floor(performance.now() / 500) % 2 === 0) {
        this.ctx.fillStyle = 'white';
        this.ctx.fillText('[ TAP TO REINCARNATE ]', this.width / 2, this.height - 30);
      }
    }
  }
}
