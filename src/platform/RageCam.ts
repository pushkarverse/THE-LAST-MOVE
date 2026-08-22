export class RageCam {
  private static canvas: HTMLCanvasElement;
  private static mediaRecorder: MediaRecorder | null = null;
  private static chunks: Blob[] = [];
  private static isSupported = false;
  private static isRecording = false;

  static init(canvas: HTMLCanvasElement) {
    this.canvas = canvas;
    
    // Check if captureStream is supported
    if ('captureStream' in canvas && typeof window.MediaRecorder !== 'undefined') {
      try {
        const stream = (canvas as any).captureStream(30);
        this.mediaRecorder = new MediaRecorder(stream, { mimeType: 'video/webm' });
        this.isSupported = true;
        
        this.mediaRecorder.ondataavailable = (e) => {
          if (e.data && e.data.size > 0) {
            this.chunks.push(e.data);
            // Ring buffer: keep roughly the last 4 seconds
            if (this.chunks.length > 4) {
              this.chunks.shift();
            }
          }
        };
      } catch (e) {
        console.warn('RageCam: MediaRecorder setup failed. Falling back to screenshot mode.', e);
        this.isSupported = false;
      }
    } else {
      console.warn('RageCam: captureStream not supported. Falling back to screenshot mode.');
      this.isSupported = false;
    }
  }

  static start() {
    this.hideOverlay();
    if (!this.isSupported || !this.mediaRecorder) return;
    
    this.chunks = [];
    if (this.mediaRecorder.state === 'inactive') {
      this.mediaRecorder.start(1000); // emit chunk every 1000ms
      this.isRecording = true;
    }
  }

  static stopAndShow() {
    if (this.isSupported && this.mediaRecorder && this.isRecording) {
      this.mediaRecorder.onstop = () => {
        const blob = new Blob(this.chunks, { type: 'video/webm' });
        const url = URL.createObjectURL(blob);
        this.showVideoOverlay(url);
        this.mediaRecorder!.onstop = null;
      };
      this.mediaRecorder.stop();
      this.isRecording = false;
    } else {
      // Fallback
      const dataUrl = this.canvas.toDataURL('image/png');
      this.showImageOverlay(dataUrl);
    }
  }

  static hideOverlay() {
    const overlay = document.getElementById('rage-cam-overlay');
    if (overlay) overlay.style.display = 'none';
    
    const vid = document.getElementById('rage-video') as HTMLVideoElement;
    if (vid) {
      vid.pause();
      vid.src = '';
    }
  }

  private static showVideoOverlay(url: string) {
    const overlay = document.getElementById('rage-cam-overlay');
    const vid = document.getElementById('rage-video') as HTMLVideoElement;
    const img = document.getElementById('rage-img') as HTMLImageElement;
    
    if (overlay && vid && img) {
      overlay.style.display = 'flex';
      img.style.display = 'none';
      vid.style.display = 'block';
      vid.src = url;
      vid.play().catch(e => console.warn('RageCam: Autoplay prevented', e));
    }
  }

  private static showImageOverlay(url: string) {
    const overlay = document.getElementById('rage-cam-overlay');
    const vid = document.getElementById('rage-video') as HTMLVideoElement;
    const img = document.getElementById('rage-img') as HTMLImageElement;
    
    if (overlay && vid && img) {
      overlay.style.display = 'flex';
      vid.style.display = 'none';
      img.style.display = 'block';
      img.src = url;
    }
  }
}
