export enum InputKind { MOVE = 0, TAP = 1, CONTINUE = 2, NONE = 3 }
export enum Dir { NONE = 0, UP = 1, DOWN = 2, LEFT = 3, RIGHT = 4 }

export interface InputEvent { kind: InputKind; dir: Dir; }
export interface LoggedInput { tick: number; ev: InputEvent; }

export class InputLog {
  private static entries: LoggedInput[] = [];

  static record(tick: number, inputs: InputEvent[]) {
    for (const ev of inputs) {
      this.entries.push({ tick, ev });
    }
  }

  static getEntries() {
    return this.entries;
  }

  static clear() {
    this.entries = [];
  }
}
