import type { Skill } from './core.ts';
import { MATH_SKILLS } from './math.ts';
import { VIETNAMESE_SKILLS } from './vietnamese.ts';

export * from './core.ts';
export { MATH_SKILLS, VIETNAMESE_SKILLS };

export const ALL_SKILLS: Skill[] = [...MATH_SKILLS, ...VIETNAMESE_SKILLS];

export function getSkill(id: string): Skill | undefined {
  return ALL_SKILLS.find((s) => s.id === id);
}
