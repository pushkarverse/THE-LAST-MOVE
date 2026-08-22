import { TICK_MS } from '../engine/constants';
import { Room } from './RoomLoader';

export class TelegraphScheduler {
  static getActiveTell(room: Room | null, tickInState: number, isWinBanner: boolean, isLastMove: boolean): string | null {
    if (!room) return null;

    const msInState = tickInState * TICK_MS;

    if (isWinBanner) {
      if (msInState >= room.last_move.tell.start_ms) {
        return room.last_move.tell.type;
      }
    } else if (isLastMove) {
      return room.last_move.tell.type;
    }

    return null;
  }
}
