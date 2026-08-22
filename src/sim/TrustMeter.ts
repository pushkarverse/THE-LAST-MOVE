import { BufferedAction } from '../flow/states';
import { TICK_MS } from '../engine/constants';

export class TrustMeter {
  private static score: number = 50;

  static getScore(): number {
    return this.score;
  }

  static getParanoia(): number {
    return 100 - this.score;
  }

  static evaluate(survived: boolean, buffer: BufferedAction[]) {
    if (!survived) {
      this.score -= 20;
    } else {
      if (buffer.length === 0) {
        this.score += 10;
      }
    }

    const jitterThresholdTicks = Math.floor(500 / TICK_MS);
    const jitter = buffer.some(a => a.atTick <= jitterThresholdTicks);

    if (jitter) {
      this.score -= 5;
    }

    this.score = Math.max(0, Math.min(100, this.score));
  }
}
