let cachedVoice: SpeechSynthesisVoice | null | undefined;

export const canSpeak = typeof window !== 'undefined' && 'speechSynthesis' in window;

function vietnameseVoice(): SpeechSynthesisVoice | null {
  if (cachedVoice !== undefined && cachedVoice !== null) return cachedVoice;
  const voices = window.speechSynthesis.getVoices();
  cachedVoice = voices.find((v) => v.lang?.toLowerCase().startsWith('vi')) ?? null;
  return cachedVoice;
}

/** Đọc đề cho bé nghe (dùng giọng tiếng Việt có sẵn trên máy nếu có). */
export function speak(text: string): void {
  if (!canSpeak) return;
  const synth = window.speechSynthesis;
  synth.cancel();
  const spoken = text
    .replace(/_{2,}/g, ' chỗ trống ')
    .replace(/×/g, ' nhân ')
    .replace(/(\d)\s*:\s*(\d)/g, '$1 chia $2')
    .replace(/=\s*\?/g, ' bằng bao nhiêu')
    .replace(/=/g, ' bằng ')
    .replace(/\+/g, ' cộng ')
    .replace(/\s-\s/g, ' trừ ')
    .replace(/\s>\s/g, ' lớn hơn ')
    .replace(/\s<\s/g, ' bé hơn ');
  const u = new SpeechSynthesisUtterance(spoken);
  u.lang = 'vi-VN';
  u.rate = 0.9;
  const voice = vietnameseVoice();
  if (voice) u.voice = voice;
  synth.speak(u);
}

export function stopSpeaking(): void {
  if (canSpeak) window.speechSynthesis.cancel();
}
