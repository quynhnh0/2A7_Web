const MUTE_KEY = 'hv_mute';
let ctx: AudioContext | null = null;

export function isMuted(): boolean {
  return localStorage.getItem(MUTE_KEY) === '1';
}

export function setMuted(muted: boolean): void {
  localStorage.setItem(MUTE_KEY, muted ? '1' : '0');
}

function tone(freqs: number[], duration = 0.12, type: OscillatorType = 'sine'): void {
  if (isMuted()) return;
  try {
    ctx ??= new AudioContext();
    const start = ctx.currentTime;
    freqs.forEach((f, i) => {
      const osc = ctx!.createOscillator();
      const gain = ctx!.createGain();
      osc.type = type;
      osc.frequency.value = f;
      const t = start + i * duration;
      gain.gain.setValueAtTime(0.0001, t);
      gain.gain.exponentialRampToValueAtTime(0.18, t + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, t + duration);
      osc.connect(gain).connect(ctx!.destination);
      osc.start(t);
      osc.stop(t + duration + 0.02);
    });
  } catch (e) {
    console.warn('[sfx] Không phát được âm thanh:', e);
  }
}

export const playCorrect = () => tone([660, 880, 1320], 0.1, 'triangle');
export const playWrong = () => tone([300, 220], 0.16, 'sine');
export const playFinish = () => tone([523, 659, 784, 1047], 0.13, 'triangle');
