import { InputLog } from './InputLog';
import { GameFlow } from '../flow/GameFlow.ts';
import { Input } from '../platform/Input';
import { Renderer } from '../render/Renderer';

import { TICK_MS } from './constants';
const MAX_FRAME_MS = 250;

let accumulator = 0;
let lastTime = 0;
let tickCount = 0;
let isRunning = false;

function frame(now: number) {
  if (!isRunning) return;

  if (lastTime === 0) {
    lastTime = now;
  }

  let delta = now - lastTime;
  lastTime = now;
  
  if (delta > MAX_FRAME_MS) {
    delta = MAX_FRAME_MS;
  }
  
  accumulator += delta;

  while (accumulator >= TICK_MS) {
    const inputs = Input.drainForTick(tickCount);
    
    GameFlow.tick(inputs);
    
    if (inputs.length > 0) {
      InputLog.record(tickCount, inputs);
    }
    
    tickCount++;
    accumulator -= TICK_MS;
  }

  const alpha = accumulator / TICK_MS;
  Renderer.draw(GameFlow.getState(), alpha);
  
  requestAnimationFrame(frame);
}

export const TickEngine = {
  start() {
    if (isRunning) return;
    isRunning = true;
    lastTime = performance.now();
    requestAnimationFrame(frame);
  },
  stop() {
    isRunning = false;
  },
  getTickCount() {
    return tickCount;
  }
};
