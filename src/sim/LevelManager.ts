import { RoomLoader, Room } from './RoomLoader';

export class LevelManager {
  private static sequence = [
    '1-01', '1-02', '1-03', '1-05', '1-08', '1-12'
  ];
  private static currentIndex = 0;
  private static currentRoom: Room | null = null;
  private static ready = false;

  static async loadNextRoom() {
    this.ready = false;
    
    if (this.currentIndex < this.sequence.length) {
      const id = this.sequence[this.currentIndex];
      try {
        this.currentRoom = await RoomLoader.loadRoom(id);
        this.ready = true;
      } catch (e) {
        console.error("Failed to load room", id, e);
      }
    } else {
      // Loop back for MVP
      this.currentIndex = 0;
      this.loadNextRoom();
    }
  }

  static async reloadCurrentRoom() {
    this.ready = false;
    const id = this.sequence[this.currentIndex];
    try {
      this.currentRoom = await RoomLoader.loadRoom(id);
      this.ready = true;
    } catch (e) {
      console.error("Failed to reload room", id, e);
    }
  }

  static advance() {
    this.currentIndex++;
  }

  static initFromProfile(maxIndex: number) {
    if (maxIndex < this.sequence.length) {
      this.currentIndex = maxIndex;
    }
  }

  static getCurrentIndex() {
    return this.currentIndex;
  }

  static resetSequence() {
    this.currentIndex = 0;
  }

  static isReady() {
    return this.ready;
  }

  static getRoom() {
    return this.currentRoom;
  }
}
