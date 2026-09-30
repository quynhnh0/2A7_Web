export type Difficulty = 1 | 2 | 3;
export type QuestionType = 'multiple_choice' | 'number' | 'text';
export type Rng = () => number;

export interface GeneratedQuestion {
  difficulty: Difficulty;
  question_type: QuestionType;
  question_text: string;
  options: string[] | null;
  correct_answer: string;
  accepted_answers: string[] | null;
  explanation: string | null;
  skill_tag: string;
  generator_type: string;
}

export type QuestionDraft = Omit<GeneratedQuestion, 'difficulty' | 'skill_tag' | 'generator_type'>;

export interface Skill {
  id: string;
  subject: 'toan' | 'tieng_viet';
  name: string;
  example: string;
  generate: (difficulty: Difficulty, rng: Rng) => QuestionDraft;
}

// mulberry32: đủ tốt cho sinh đề, có seed để tái lập được ngân hàng câu hỏi mẫu.
export function createRng(seed: number = Date.now()): Rng {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

export function randInt(rng: Rng, min: number, max: number): number {
  return Math.floor(rng() * (max - min + 1)) + min;
}

export function pick<T>(rng: Rng, items: readonly T[]): T {
  return items[Math.floor(rng() * items.length)];
}

export function shuffle<T>(rng: Rng, items: readonly T[]): T[] {
  const out = items.slice();
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

export function numberQ(text: string, answer: number | string, explanation: string | null = null): QuestionDraft {
  return {
    question_type: 'number',
    question_text: text,
    options: null,
    correct_answer: String(answer),
    accepted_answers: null,
    explanation,
  };
}

export function textQ(text: string, answer: string, accepted: string[] | null = null, explanation: string | null = null): QuestionDraft {
  return {
    question_type: 'text',
    question_text: text,
    options: null,
    correct_answer: answer,
    accepted_answers: accepted && accepted.length ? accepted : null,
    explanation,
  };
}

export function choiceQ(rng: Rng, text: string, answer: string, distractors: string[], explanation: string | null = null, keepOrder = false): QuestionDraft {
  const unique: string[] = [];
  for (const d of distractors) {
    if (d !== answer && !unique.includes(d)) unique.push(d);
  }
  const options = [answer, ...unique.slice(0, 3)];
  return {
    question_type: 'multiple_choice',
    question_text: text,
    options: keepOrder ? options : shuffle(rng, options),
    correct_answer: answer,
    accepted_answers: null,
    explanation,
  };
}

export function numberDistractors(rng: Rng, answer: number, min = 0, max = 1000): string[] {
  const candidates = shuffle(rng, [answer + 1, answer - 1, answer + 10, answer - 10, answer + 2, answer - 2]);
  const out: string[] = [];
  for (const c of candidates) {
    if (c >= min && c <= max && c !== answer && !out.includes(String(c))) out.push(String(c));
    if (out.length === 3) break;
  }
  return out;
}

export function numberChoiceQ(rng: Rng, text: string, answer: number, explanation: string | null = null): QuestionDraft {
  return choiceQ(rng, text, String(answer), numberDistractors(rng, answer), explanation);
}

export function questionKey(q: { question_text: string; options?: (string | null | undefined)[] | null }): string {
  const opts = (q.options ?? []).filter((o): o is string => !!o).map((o) => o.trim()).sort();
  return q.question_text.trim().replace(/\s+/g, ' ') + '|' + opts.join('¦');
}

export function generateBatch(
  skills: Skill[],
  counts: { easy: number; normal: number; advanced: number },
  rng: Rng,
  existingKeys: Iterable<string> = [],
): GeneratedQuestion[] {
  const seen = new Set<string>(existingKeys);
  const out: GeneratedQuestion[] = [];
  const plan: Array<[Difficulty, number]> = [[1, counts.easy], [2, counts.normal], [3, counts.advanced]];
  let skillCursor = 0;
  for (const [difficulty, count] of plan) {
    let made = 0;
    let tries = 0;
    while (made < count && tries < count * 40) {
      tries++;
      const skill = skills[skillCursor % skills.length];
      skillCursor++;
      const draft = skill.generate(difficulty, rng);
      const key = questionKey(draft);
      if (seen.has(key)) continue;
      seen.add(key);
      out.push({ ...draft, difficulty, skill_tag: skill.id, generator_type: 'rule:' + skill.id });
      made++;
    }
  }
  return out;
}
