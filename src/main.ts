import { TickEngine } from './engine/TickEngine';
import { Renderer } from './render/Renderer';
import { Input } from './platform/Input';
import { AudioMix } from './platform/AudioMix';
import { RageCam } from './platform/RageCam';
import { GraveLogDb } from './platform/GraveLogDb';
import { ProfileDb } from './platform/ProfileDb';
import { Analytics } from './platform/Analytics';
import { LevelManager } from './sim/LevelManager';

async function init() {
  const canvas = document.getElementById('gameCanvas') as HTMLCanvasElement;
  Renderer.init('gameCanvas');
  Input.init();
  AudioMix.init();
  RageCam.init(canvas);
  await GraveLogDb.init();
  ProfileDb.init();
  Analytics.init();
  
  LevelManager.initFromProfile(ProfileDb.getProfile().maxRoomIndex);

  try {
    // Start loop
    TickEngine.start();
  } catch (err) {
    console.error("Failed to start game:", err);
    document.body.innerHTML = `<h1 style="color:red; text-align:center; font-family:monospace">FATAL ERROR:<br/>${err}</h1>`;
  }
}

// Start once DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
