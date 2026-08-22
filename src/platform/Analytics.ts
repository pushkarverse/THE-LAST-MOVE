export class Analytics {
  static init() {
    console.log("[Analytics] Initialized");
  }

  static trackLevelStart(roomId: string) {
    console.log(`[Analytics] level_start: ${roomId}`);
  }

  static trackTrapSurvived(roomId: string, rule: string) {
    console.log(`[Analytics] trap_survived: ${roomId} (${rule})`);
  }

  static trackTrapFailed(roomId: string, rule: string, t_relax: number) {
    console.log(`[Analytics] trap_failed: ${roomId} (${rule}) | t_relax=${t_relax}ms`);
  }
}
