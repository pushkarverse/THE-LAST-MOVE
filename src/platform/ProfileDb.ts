export interface SaveProfile {
  maxRoomIndex: number;
  highScore: number;
  totalDeaths: number;
}

export class ProfileDb {
  private static profile: SaveProfile = { maxRoomIndex: 0, highScore: 0, totalDeaths: 0 };

  static init() {
    const saved = localStorage.getItem('TheLastMoveProfile');
    if (saved) {
      try {
        this.profile = JSON.parse(saved);
      } catch (e) {}
    }
  }

  static getProfile() { return this.profile; }

  static updateMaxRoom(index: number) {
    if (index > this.profile.maxRoomIndex) {
      this.profile.maxRoomIndex = index;
      this.save();
    }
  }
  
  static addScore(score: number) {
    this.profile.highScore += score;
    this.save();
  }

  static addDeath() {
    this.profile.totalDeaths++;
    this.save();
  }

  private static save() {
    localStorage.setItem('TheLastMoveProfile', JSON.stringify(this.profile));
  }
}
