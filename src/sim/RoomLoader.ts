import Ajv from "ajv";
import { roomSchema } from "./RoomSchema";

export interface Point { x: number, y: number }
export interface RoomExit extends Point { is_real: boolean, has_shadow?: boolean }

export interface Room {
  id: string;
  grid: { w: number, h: number };
  player_start: Point;
  walls: Point[];
  exits: RoomExit[];
  last_move: {
    rule: string;
    window_ms: number;
    tell: {
      type: string;
      start_ms: number;
    };
    mutations?: string[];
  }
}

const ajv = new Ajv();
const validate = ajv.compile(roomSchema);

export class RoomLoader {
  static async loadRoom(id: string): Promise<Room> {
    const response = await fetch(`/rooms/${id}.json`);
    if (!response.ok) {
      throw new Error(`Failed to load room ${id}: ${response.statusText}`);
    }
    
    const data = await response.json();
    const valid = validate(data);
    
    if (!valid) {
      console.error("Room validation errors:", validate.errors);
      throw new Error(`Room JSON for ${id} is malformed! See console for details.`);
    }
    
    return data as unknown as Room;
  }
}
