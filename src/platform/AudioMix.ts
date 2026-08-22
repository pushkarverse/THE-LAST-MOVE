export class AudioMix {
  private static ctx: AudioContext | null = null;
  private static unlocked = false;

  static init() {
    if (!this.ctx) {
      // @ts-expect-error fallback
      const AudioContextCtor = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioContextCtor();
    }
  }

  static unlock() {
    if (this.unlocked || !this.ctx) return;
    this.ctx.resume().then(() => {
      this.unlocked = true;
    });
  }

  static playFanfare() {
    if (!this.unlocked || !this.ctx) return;
    const ctx = this.ctx;
    
    // Play a victorious C major arpeggio
    const freqs = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
    const t = ctx.currentTime;
    
    freqs.forEach((freq, i) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      
      osc.type = 'square';
      osc.frequency.value = freq;
      
      osc.connect(gain);
      gain.connect(ctx.destination);
      
      // +6dB volume boost (loud fanfare)
      gain.gain.setValueAtTime(0, t);
      gain.gain.linearRampToValueAtTime(0.5, t + 0.05 + i * 0.1);
      gain.gain.exponentialRampToValueAtTime(0.01, t + 0.5 + i * 0.1);
      
      osc.start(t + i * 0.1);
      osc.stop(t + 0.6 + i * 0.1);
    });
  }

  static playTellWhisper() {
    if (!this.unlocked || !this.ctx) return;
    const ctx = this.ctx;
    
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    
    osc.type = 'sine';
    osc.frequency.value = 55; // Low dissonant drone
    
    osc.connect(gain);
    gain.connect(ctx.destination);
    
    const t = ctx.currentTime;
    gain.gain.setValueAtTime(0, t);
    gain.gain.linearRampToValueAtTime(0.3, t + 0.1);
    gain.gain.linearRampToValueAtTime(0.01, t + 1.0);
    
    osc.start(t);
    osc.stop(t + 1.0);
  }
}
