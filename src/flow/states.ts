import { InputEvent } from '../engine/InputLog';

export enum FlowState {
  BOOT,
  ROOM_LOAD,
  SOLVE,
  EXIT_TOUCHED,
  WIN_BANNER,
  LAST_MOVE_WINDOW,
  RESOLVE,
  DEATH,
  SURVIVE,
  RAGE_CAM,
  GRAVE_LOG,
  ROOM_RELOAD,
  SCORE_TALLY,
  GRAVEYARD,
}

export interface BufferedAction {
  atTick: number;
  ev: InputEvent;
}
