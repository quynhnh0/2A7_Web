import {
  choiceQ, numberChoiceQ, numberQ, pick, randInt,
  type Difficulty, type QuestionDraft, type Rng, type Skill,
} from './core.ts';

const NAMES = ['Lan', 'Hoa', 'Nam', 'Minh', 'Mai', 'An', 'Bình', 'Hà', 'Tú', 'Linh', 'Khôi', 'Ngọc'];
const OBJECTS = ['quả táo', 'cái kẹo', 'bông hoa', 'quyển vở', 'viên bi', 'cái bút chì', 'quả cam', 'con tem', 'nhãn vở'];

function twoNames(rng: Rng): [string, string] {
  const a = pick(rng, NAMES);
  let b = pick(rng, NAMES);
  while (b === a) b = pick(rng, NAMES);
  return [a, b];
}

function compareSign(a: number, b: number): string {
  return a > b ? '>' : a < b ? '<' : '=';
}

function compareQ(left: string, right: string, lv: number, rv: number): QuestionDraft {
  const ans = compareSign(lv, rv);
  const steps: string[] = [];
  if (left !== String(lv)) steps.push(`${left} = ${lv}`);
  if (right !== String(rv)) steps.push(`${right} = ${rv}`);
  steps.push(`${lv} ${ans} ${rv}`);
  return {
    question_type: 'multiple_choice',
    question_text: `Chọn dấu thích hợp:  ${left}  ___  ${right}`,
    options: ['>', '<', '='],
    correct_answer: ans,
    accepted_answers: null,
    explanation: steps.join('; ') + '.',
  };
}

// Cộng 2 số có tổng không nhớ ở hàng đơn vị và hàng chục.
function addNoCarry(rng: Rng, twoDigit: boolean): [number, number] {
  if (!twoDigit) {
    const u1 = randInt(rng, 0, 8);
    const u2 = randInt(rng, 1, 9 - u1);
    return [10 + u1, u2];
  }
  const t1 = randInt(rng, 1, 8), t2 = randInt(rng, 1, 9 - t1);
  const u1 = randInt(rng, 0, 9), u2 = randInt(rng, 0, 9 - u1);
  return [t1 * 10 + u1, t2 * 10 + u2];
}

function subNoBorrow(rng: Rng, twoDigit: boolean): [number, number] {
  if (!twoDigit) {
    const u1 = randInt(rng, 1, 9);
    return [10 + u1, randInt(rng, 1, u1)];
  }
  const t1 = randInt(rng, 2, 9), t2 = randInt(rng, 1, t1 - 1);
  const u1 = randInt(rng, 0, 9), u2 = randInt(rng, 0, u1);
  return [t1 * 10 + u1, t2 * 10 + u2];
}

function addCarry20(rng: Rng, easy: boolean): [number, number] {
  const a = easy ? pick(rng, [9, 9, 8]) : randInt(rng, 5, 8);
  const b = randInt(rng, 11 - a, 9);
  return [a, b];
}

function subBorrow20(rng: Rng, easy: boolean): [number, number] {
  if (easy) {
    return pick(rng, [true, false]) ? [11, randInt(rng, 2, 9)] : [randInt(rng, 11, 18), 9];
  }
  const m = randInt(rng, 11, 18);
  const n = randInt(rng, m - 9, 9);
  return [m, n];
}

function addCarry100(rng: Rng, twoDigit: boolean): [number, number] {
  const u1 = randInt(rng, 2, 9);
  const u2 = randInt(rng, 10 - u1, 9);
  if (!twoDigit) {
    const t = randInt(rng, 1, 8);
    return [t * 10 + u1, u2];
  }
  const t1 = randInt(rng, 1, 7);
  const t2 = randInt(rng, 1, 8 - t1);
  return [t1 * 10 + u1, t2 * 10 + u2];
}

function subBorrow100(rng: Rng, twoDigit: boolean): [number, number] {
  const u1 = randInt(rng, 0, 8);
  const u2 = randInt(rng, u1 + 1, 9);
  if (!twoDigit) {
    const t = randInt(rng, 2, 9);
    return [t * 10 + u1, u2];
  }
  const t1 = randInt(rng, 3, 9);
  const t2 = randInt(rng, 1, t1 - 2);
  return [t1 * 10 + u1, t2 * 10 + u2];
}

function missingAdd(a: number, b: number, rng: Rng): QuestionDraft {
  const s = a + b;
  return pick(rng, [true, false])
    ? numberQ(`${a} + ___ = ${s}`, b, `Lấy tổng trừ số hạng đã biết: ${s} - ${a} = ${b}.`)
    : numberQ(`___ + ${b} = ${s}`, a, `Lấy tổng trừ số hạng đã biết: ${s} - ${b} = ${a}.`);
}

function missingSub(m: number, n: number, rng: Rng): QuestionDraft {
  const h = m - n;
  return pick(rng, [true, false])
    ? numberQ(`${m} - ___ = ${h}`, n, `Số trừ = số bị trừ - hiệu: ${m} - ${h} = ${n}.`)
    : numberQ(`___ - ${n} = ${h}`, m, `Số bị trừ = hiệu + số trừ: ${h} + ${n} = ${m}.`);
}

function plainAdd(rng: Rng, a: number, b: number): QuestionDraft {
  return pick(rng, [0, 0, 1])
    ? numberChoiceQ(rng, `${a} + ${b} = ?`, a + b)
    : numberQ(`${a} + ${b} = ?`, a + b);
}

function plainSub(rng: Rng, m: number, n: number): QuestionDraft {
  return pick(rng, [0, 0, 1])
    ? numberChoiceQ(rng, `${m} - ${n} = ?`, m - n)
    : numberQ(`${m} - ${n} = ?`, m - n);
}

const soDen100: Skill = {
  id: 'so_den_100', subject: 'toan', name: 'Các số đến 100 (chục, đơn vị)',
  example: 'Số gồm 4 chục và 7 đơn vị là số nào?',
  generate(d: Difficulty, rng: Rng) {
    if (d === 1) {
      const t = randInt(rng, 1, 9), u = randInt(rng, 0, 9);
      return numberQ(`Số gồm ${t} chục và ${u} đơn vị là số nào?`, t * 10 + u, `${t} chục là ${t * 10}, thêm ${u} đơn vị được ${t * 10 + u}.`);
    }
    if (d === 2) {
      const t = randInt(rng, 1, 9), u = randInt(rng, 1, 9);
      const n = t * 10 + u;
      const opts = [`${u} chục và ${t} đơn vị`, `${t} chục và ${(u + 1) % 10} đơn vị`, `${(t % 9) + 1} chục và ${u} đơn vị`, `${t} đơn vị và ${u} đơn vị`];
      return choiceQ(rng, `Số ${n} gồm:`, `${t} chục và ${u} đơn vị`, opts, `Chữ số ${t} ở hàng chục, chữ số ${u} ở hàng đơn vị.`);
    }
    const v = randInt(rng, 0, 2);
    if (v === 0) {
      let n = randInt(rng, 11, 99);
      if (n % 10 === 0) n += 3;
      return numberQ(`Số tròn chục lớn nhất bé hơn ${n} là số nào?`, Math.floor(n / 10) * 10);
    }
    if (v === 1) {
      let n = randInt(rng, 11, 89);
      if (n % 10 === 0) n += 4;
      return numberQ(`Số tròn chục liền sau số ${n} là số nào?`, (Math.floor(n / 10) + 1) * 10);
    }
    const x = randInt(rng, 1, 9);
    let y = randInt(rng, 1, 9);
    while (y === x) y = randInt(rng, 1, 9);
    const big = Math.max(x * 10 + y, y * 10 + x);
    return numberQ(`Từ hai chữ số ${x} và ${y}, viết được số lớn nhất có hai chữ số khác nhau là số nào?`, big, `Đặt chữ số lớn hơn ở hàng chục: ${big}.`);
  },
};

const lienTruocLienSau: Skill = {
  id: 'lien_truoc_lien_sau', subject: 'toan', name: 'Số liền trước, số liền sau',
  example: 'Số liền sau của 35 là số nào?',
  generate(d, rng) {
    if (d === 1) {
      if (pick(rng, [true, false])) {
        const n = randInt(rng, 1, 98);
        return numberQ(`Số liền sau của ${n} là số nào?`, n + 1, `Số liền sau thì hơn số đó 1 đơn vị: ${n} + 1 = ${n + 1}.`);
      }
      const n = randInt(rng, 2, 99);
      return numberQ(`Số liền trước của ${n} là số nào?`, n - 1, `Số liền trước thì kém số đó 1 đơn vị: ${n} - 1 = ${n - 1}.`);
    }
    if (d === 2) {
      const n = randInt(rng, 2, 9) * 10;
      if (pick(rng, [true, false])) {
        return choiceQ(rng, `Số liền trước của ${n} là:`, String(n - 1), [String(n + 1), String(n - 10), String(n - 2)]);
      }
      const m = randInt(rng, 11, 98);
      return numberQ(`Ba số liên tiếp:  ${m - 1},  ___,  ${m + 1}`, m);
    }
    const v = randInt(rng, 0, 2);
    const n = randInt(rng, 12, 97);
    if (v === 0) return numberQ(`Số liền sau của số liền trước ${n} là số nào?`, n, `Số liền trước ${n} là ${n - 1}; số liền sau ${n - 1} là ${n}.`);
    if (v === 1) return numberQ(`Số liền trước của số liền trước ${n} là số nào?`, n - 2, `${n} → ${n - 1} → ${n - 2}.`);
    return numberQ(`Số liền sau của số liền sau ${n} là số nào?`, n + 2, `${n} → ${n + 1} → ${n + 2}.`);
  },
};

const soSanh: Skill = {
  id: 'so_sanh', subject: 'toan', name: 'So sánh số (>, <, =)',
  example: '25 ___ 52',
  generate(d, rng) {
    if (d === 1) {
      const a = randInt(rng, 10, 99);
      let b = randInt(rng, 10, 99);
      if (pick(rng, [true, false])) b = (a % 10) * 10 + Math.floor(a / 10);
      if (b < 10) b = a + 1 > 99 ? a - 1 : a + 1;
      return compareQ(String(a), String(b), a, b);
    }
    if (d === 2) {
      const [a, b] = addNoCarry(rng, true);
      const s = a + b;
      const c = s + pick(rng, [-1, 0, 1, -10, 10, 0]);
      return compareQ(`${a} + ${b}`, String(c), s, c);
    }
    const [a, b] = addNoCarry(rng, true);
    const [m, n] = subNoBorrow(rng, true);
    return compareQ(`${a} + ${b}`, `${m} - ${n}`, a + b, m - n);
  },
};

const daySo: Skill = {
  id: 'day_so', subject: 'toan', name: 'Dãy số, tia số',
  example: '10, 20, 30, ___',
  generate(d, rng) {
    if (d === 1) {
      const step = pick(rng, [1, 10]);
      const s = step === 10 ? randInt(rng, 0, 6) * 10 : randInt(rng, 10, 90);
      return numberQ(`Điền số tiếp theo:  ${s},  ${s + step},  ${s + 2 * step},  ___`, s + 3 * step, `Mỗi số hơn số trước ${step} đơn vị.`);
    }
    if (d === 2) {
      const step = pick(rng, [2, 5]);
      const s = step * randInt(rng, 0, 15);
      return numberQ(`Điền số còn thiếu:  ${s},  ${s + step},  ___,  ${s + 3 * step}`, s + 2 * step, `Mỗi số hơn số trước ${step} đơn vị.`);
    }
    const step = pick(rng, [2, 3, 5, 10]);
    const s = randInt(rng, 4 * step, 99);
    return numberQ(`Điền số tiếp theo:  ${s},  ${s - step},  ${s - 2 * step},  ___`, s - 3 * step, `Mỗi số kém số trước ${step} đơn vị.`);
  },
};

const thanhPhan: Skill = {
  id: 'thanh_phan_phep_tinh', subject: 'toan', name: 'Số hạng, tổng, số bị trừ, số trừ, hiệu',
  example: 'Trong phép tính 12 + 5 = 17, số 17 được gọi là gì?',
  generate(d, rng) {
    if (d === 1) {
      if (pick(rng, [true, false])) {
        const [a, b] = addNoCarry(rng, pick(rng, [true, false]));
        const askSum = pick(rng, [true, false]);
        return choiceQ(rng, `Trong phép tính ${a} + ${b} = ${a + b}, số ${askSum ? a + b : a} được gọi là:`,
          askSum ? 'Tổng' : 'Số hạng', ['Tổng', 'Số hạng', 'Hiệu', 'Số trừ']);
      }
      const [m, n] = subNoBorrow(rng, pick(rng, [true, false]));
      // Nếu số trừ = hiệu (vd 20 - 10 = 10) thì hỏi số bị trừ để tránh mơ hồ.
      const which = n === m - n ? 0 : randInt(rng, 0, 2);
      const val = [m, n, m - n][which];
      const name = ['Số bị trừ', 'Số trừ', 'Hiệu'][which];
      return choiceQ(rng, `Trong phép tính ${m} - ${n} = ${m - n}, số ${val} được gọi là:`, name, ['Số bị trừ', 'Số trừ', 'Hiệu', 'Tổng']);
    }
    if (d === 2) {
      if (pick(rng, [true, false])) {
        const [a, b] = addNoCarry(rng, true);
        return numberQ(`Tổng của ${a} và ${b} là bao nhiêu?`, a + b, `${a} + ${b} = ${a + b}.`);
      }
      const [m, n] = subNoBorrow(rng, true);
      return numberQ(`Hiệu của ${m} và ${n} là bao nhiêu?`, m - n, `${m} - ${n} = ${m - n}.`);
    }
    if (pick(rng, [true, false])) {
      const [a, b] = addNoCarry(rng, true);
      return numberQ(`Số hạng thứ nhất là ${a}, tổng là ${a + b}. Số hạng thứ hai là bao nhiêu?`, b, `${a + b} - ${a} = ${b}.`);
    }
    const [m, n] = subNoBorrow(rng, true);
    return numberQ(`Số trừ là ${n}, hiệu là ${m - n}. Số bị trừ là bao nhiêu?`, m, `${m - n} + ${n} = ${m}.`);
  },
};

const honKem: Skill = {
  id: 'hon_kem', subject: 'toan', name: 'Hơn, kém nhau bao nhiêu',
  example: '8 hơn 5 bao nhiêu?',
  generate(d, rng) {
    if (d === 1) {
      const a = randInt(rng, 5, 20), b = randInt(rng, 1, a - 1);
      return pick(rng, [true, false])
        ? numberQ(`${a} hơn ${b} bao nhiêu?`, a - b, `${a} - ${b} = ${a - b}.`)
        : numberQ(`${b} kém ${a} bao nhiêu?`, a - b, `${a} - ${b} = ${a - b}.`);
    }
    if (d === 2) {
      const [a, b] = subNoBorrow(rng, true);
      const [n1, n2] = twoNames(rng);
      const obj = pick(rng, OBJECTS);
      return numberQ(`${n1} có ${a} ${obj}, ${n2} có ${b} ${obj}. Hỏi ${n1} có nhiều hơn ${n2} bao nhiêu ${obj}?`, a - b, `${a} - ${b} = ${a - b}.`);
    }
    const a = randInt(rng, 20, 60), k = randInt(rng, 3, 30);
    return pick(rng, [true, false])
      ? numberQ(`Số nào hơn ${a} là ${k} đơn vị?`, a + k, `${a} + ${k} = ${a + k}.`)
      : numberQ(`Số nào kém ${a} là ${Math.min(k, a - 1)} đơn vị?`, a - Math.min(k, a - 1), `${a} - ${Math.min(k, a - 1)} = ${a - Math.min(k, a - 1)}.`);
  },
};

const congKhongNho: Skill = {
  id: 'cong_khong_nho_100', subject: 'toan', name: 'Phép cộng không nhớ trong phạm vi 100',
  example: '32 + 45 = ?',
  generate(d, rng) {
    if (d === 1) { const [a, b] = addNoCarry(rng, false); return plainAdd(rng, a, b); }
    if (d === 2) { const [a, b] = addNoCarry(rng, true); return plainAdd(rng, a, b); }
    const [a, b] = addNoCarry(rng, true);
    return missingAdd(a, b, rng);
  },
};

const truKhongNho: Skill = {
  id: 'tru_khong_nho_100', subject: 'toan', name: 'Phép trừ không nhớ trong phạm vi 100',
  example: '68 - 25 = ?',
  generate(d, rng) {
    if (d === 1) { const [m, n] = subNoBorrow(rng, false); return plainSub(rng, m, n); }
    if (d === 2) { const [m, n] = subNoBorrow(rng, true); return plainSub(rng, m, n); }
    const [m, n] = subNoBorrow(rng, true);
    return missingSub(m, n, rng);
  },
};

const congQua10: Skill = {
  id: 'cong_qua_10', subject: 'toan', name: 'Phép cộng (qua 10) trong phạm vi 20',
  example: '9 + 5 = ?',
  generate(d, rng) {
    if (d === 1) {
      const [a, b] = addCarry20(rng, true);
      return numberQ(`${a} + ${b} = ?`, a + b, `Tách ${b} = ${10 - a} + ${b - (10 - a)}; ${a} + ${10 - a} = 10; 10 + ${b - (10 - a)} = ${a + b}.`);
    }
    if (d === 2) { const [a, b] = addCarry20(rng, false); return plainAdd(rng, a, b); }
    if (pick(rng, [true, false])) { const [a, b] = addCarry20(rng, false); return missingAdd(a, b, rng); }
    const a = randInt(rng, 2, 9), b = randInt(rng, 2, 9);
    const c = randInt(rng, 1, Math.max(1, 20 - a - b));
    if (a + b + c > 20) return numberQ(`${a} + ${b} = ?`, a + b);
    return numberQ(`${a} + ${b} + ${c} = ?`, a + b + c, `${a} + ${b} = ${a + b}; ${a + b} + ${c} = ${a + b + c}.`);
  },
};

const truQua10: Skill = {
  id: 'tru_qua_10', subject: 'toan', name: 'Phép trừ (qua 10) trong phạm vi 20',
  example: '13 - 5 = ?',
  generate(d, rng) {
    if (d === 1) {
      const [m, n] = subBorrow20(rng, true);
      return numberQ(`${m} - ${n} = ?`, m - n, `${m} - ${m - 10} = 10; 10 - ${n - (m - 10)} = ${m - n}.`);
    }
    if (d === 2) { const [m, n] = subBorrow20(rng, false); return plainSub(rng, m, n); }
    const [m, n] = subBorrow20(rng, false);
    return missingSub(m, n, rng);
  },
};

const congCoNho: Skill = {
  id: 'cong_co_nho_100', subject: 'toan', name: 'Phép cộng có nhớ trong phạm vi 100',
  example: '27 + 18 = ?',
  generate(d, rng) {
    if (d === 1) { const [a, b] = addCarry100(rng, false); return plainAdd(rng, a, b); }
    if (d === 2) {
      const [a, b] = addCarry100(rng, true);
      return numberQ(`${a} + ${b} = ?`, a + b, `Cộng hàng đơn vị: ${a % 10} + ${b % 10} = ${(a % 10) + (b % 10)}, viết ${(a + b) % 10} nhớ 1.`);
    }
    if (pick(rng, [true, false])) { const [a, b] = addCarry100(rng, true); return missingAdd(a, b, rng); }
    const [a, b] = addCarry100(rng, true);
    const [n1, n2] = twoNames(rng);
    const obj = pick(rng, OBJECTS);
    return numberQ(`${n1} có ${a} ${obj}, ${n2} có ${b} ${obj}. Hỏi cả hai bạn có tất cả bao nhiêu ${obj}?`, a + b, `${a} + ${b} = ${a + b}.`);
  },
};

const truCoNho: Skill = {
  id: 'tru_co_nho_100', subject: 'toan', name: 'Phép trừ có nhớ trong phạm vi 100',
  example: '52 - 17 = ?',
  generate(d, rng) {
    if (d === 1) { const [m, n] = subBorrow100(rng, false); return plainSub(rng, m, n); }
    if (d === 2) { const [m, n] = subBorrow100(rng, true); return plainSub(rng, m, n); }
    if (pick(rng, [true, false])) { const [m, n] = subBorrow100(rng, true); return missingSub(m, n, rng); }
    const [m, n] = subBorrow100(rng, true);
    const name = pick(rng, NAMES), obj = pick(rng, OBJECTS);
    return numberQ(`${name} có ${m} ${obj}, ${name} cho bạn ${n} ${obj}. Hỏi ${name} còn lại bao nhiêu ${obj}?`, m - n, `${m} - ${n} = ${m - n}.`);
  },
};

const loiVan: Skill = {
  id: 'bai_toan_loi_van', subject: 'toan', name: 'Bài toán có lời văn (thêm, bớt, nhiều hơn, ít hơn)',
  example: 'Lan có 8 quả táo, mẹ cho thêm 5 quả. Lan có tất cả bao nhiêu quả táo?',
  generate(d, rng) {
    const name = pick(rng, NAMES);
    const obj = pick(rng, OBJECTS);
    if (d === 1) {
      if (pick(rng, [true, false])) {
        const a = randInt(rng, 3, 12), b = randInt(rng, 2, 20 - a);
        return numberQ(`${name} có ${a} ${obj}, mẹ cho thêm ${b} ${obj}. Hỏi ${name} có tất cả bao nhiêu ${obj}?`, a + b, `${a} + ${b} = ${a + b}.`);
      }
      const a = randInt(rng, 8, 20), b = randInt(rng, 2, a - 1);
      return numberQ(`${name} có ${a} ${obj}, ${name} cho bạn ${b} ${obj}. Hỏi ${name} còn lại bao nhiêu ${obj}?`, a - b, `${a} - ${b} = ${a - b}.`);
    }
    const [n1, n2] = twoNames(rng);
    if (d === 2) {
      if (pick(rng, [true, false])) {
        const [a, b] = addNoCarry(rng, true);
        return numberQ(`${n1} có ${a} ${obj}. ${n2} có nhiều hơn ${n1} ${b} ${obj}. Hỏi ${n2} có bao nhiêu ${obj}?`, a + b, `Nhiều hơn thì làm phép cộng: ${a} + ${b} = ${a + b}.`);
      }
      const [a, b] = subNoBorrow(rng, true);
      return numberQ(`${n1} có ${a} ${obj}. ${n2} có ít hơn ${n1} ${b} ${obj}. Hỏi ${n2} có bao nhiêu ${obj}?`, a - b, `Ít hơn thì làm phép trừ: ${a} - ${b} = ${a - b}.`);
    }
    const v = randInt(rng, 0, 2);
    if (v === 0) {
      const b = randInt(rng, 5, 30), c = randInt(rng, 5, 40);
      return numberQ(`${name} cho bạn ${b} ${obj} thì còn lại ${c} ${obj}. Hỏi lúc đầu ${name} có bao nhiêu ${obj}?`, b + c, `Lúc đầu = số đã cho + số còn lại: ${b} + ${c} = ${b + c}.`);
    }
    if (v === 1) {
      const boys = randInt(rng, 12, 20), girls = randInt(rng, 12, 20);
      return numberQ(`Lớp 2A có ${boys} bạn nam và ${girls} bạn nữ. Hỏi lớp 2A có tất cả bao nhiêu bạn?`, boys + girls, `${boys} + ${girls} = ${boys + girls}.`);
    }
    const a = randInt(rng, 20, 50), b = randInt(rng, 5, 15), c = randInt(rng, 5, 15);
    return numberQ(`Trong vườn có ${a} cây. Bố trồng thêm ${b} cây, sau đó chặt bớt ${c} cây già. Hỏi trong vườn còn bao nhiêu cây?`, a + b - c, `${a} + ${b} - ${c} = ${a + b - c}.`);
  },
};

const doDai: Skill = {
  id: 'do_dai', subject: 'toan', name: 'Đo độ dài (cm, dm, m)',
  example: '3 dm = ___ cm',
  generate(d, rng) {
    if (d === 1) {
      const k = randInt(rng, 1, 9);
      return numberQ(`${k} dm = ___ cm`, k * 10, `1 dm = 10 cm nên ${k} dm = ${k * 10} cm.`);
    }
    if (d === 2) {
      if (pick(rng, [true, false])) {
        const k = randInt(rng, 1, 9);
        return numberQ(`${k * 10} cm = ___ dm`, k, `10 cm = 1 dm nên ${k * 10} cm = ${k} dm.`);
      }
      const a = randInt(rng, 10, 50), b = randInt(rng, 5, 40);
      return numberQ(`${a} cm + ${b} cm = ___ cm`, a + b);
    }
    const v = randInt(rng, 0, 2);
    if (v === 0) {
      const k = randInt(rng, 1, 9), u = randInt(rng, 1, 9);
      return numberQ(`${k} dm ${u} cm = ___ cm`, k * 10 + u, `${k} dm = ${k * 10} cm, thêm ${u} cm được ${k * 10 + u} cm.`);
    }
    if (v === 1) return numberQ(`1 m = ___ cm`, 100, '1 m = 10 dm = 100 cm.');
    const k = randInt(rng, 1, 9), c = k * 10 + pick(rng, [-3, 0, 5]);
    return {
      question_type: 'multiple_choice',
      question_text: `Chọn dấu thích hợp:  ${k} dm  ___  ${c} cm`,
      options: ['>', '<', '='],
      correct_answer: compareSign(k * 10, c),
      accepted_answers: null,
      explanation: `${k} dm = ${k * 10} cm.`,
    };
  },
};

const khoiLuong: Skill = {
  id: 'kg_lit', subject: 'toan', name: 'Ki-lô-gam, lít',
  example: '5 kg + 3 kg = ___ kg',
  generate(d, rng) {
    const unit = pick(rng, ['kg', 'l']);
    if (d === 1) {
      const a = randInt(rng, 2, 40), b = randInt(rng, 1, 30);
      return numberQ(`${a} ${unit} + ${b} ${unit} = ___ ${unit}`, a + b);
    }
    if (d === 2) {
      const a = randInt(rng, 20, 90), b = randInt(rng, 5, a - 5);
      return numberQ(`${a} ${unit} - ${b} ${unit} = ___ ${unit}`, a - b);
    }
    if (unit === 'kg') {
      const a = randInt(rng, 25, 60), b = randInt(rng, 5, 20);
      return numberQ(`Bao gạo nặng ${a} kg, bao ngô nhẹ hơn bao gạo ${b} kg. Hỏi bao ngô nặng bao nhiêu ki-lô-gam?`, a - b, `${a} - ${b} = ${a - b}.`);
    }
    const a = randInt(rng, 10, 30), b = randInt(rng, 5, 20);
    return numberQ(`Can to đựng ${a} l nước, can bé đựng ${b} l nước. Hỏi cả hai can đựng bao nhiêu lít nước?`, a + b, `${a} + ${b} = ${a + b}.`);
  },
};

const nhan25: Skill = {
  id: 'nhan_2_5', subject: 'toan', name: 'Bảng nhân 2, bảng nhân 5',
  example: '2 × 7 = ?',
  generate(d, rng) {
    const k = randInt(rng, 1, 10);
    if (d === 1) return numberQ(`2 × ${k} = ?`, 2 * k);
    if (d === 2) return pick(rng, [true, false]) ? numberQ(`5 × ${k} = ?`, 5 * k) : numberChoiceQ(rng, `5 × ${k} = ?`, 5 * k);
    if (pick(rng, [true, false])) {
      const f = pick(rng, [2, 5]);
      return numberQ(`${f} × ___ = ${f * k}`, k, `${f * k} : ${f} = ${k}.`);
    }
    return pick(rng, [true, false])
      ? numberQ(`Mỗi con gà có 2 chân. Hỏi ${k} con gà có bao nhiêu chân?`, 2 * k, `2 × ${k} = ${2 * k}.`)
      : numberQ(`Mỗi bàn tay có 5 ngón. Hỏi ${k} bàn tay có bao nhiêu ngón?`, 5 * k, `5 × ${k} = ${5 * k}.`);
  },
};

const chia25: Skill = {
  id: 'chia_2_5', subject: 'toan', name: 'Bảng chia 2, bảng chia 5',
  example: '14 : 2 = ?',
  generate(d, rng) {
    const k = randInt(rng, 1, 10);
    if (d === 1) return numberQ(`${2 * k} : 2 = ?`, k);
    if (d === 2) return numberQ(`${5 * k} : 5 = ?`, k);
    const obj = pick(rng, OBJECTS);
    return pick(rng, [true, false])
      ? numberQ(`Có ${2 * k} ${obj} chia đều cho 2 bạn. Hỏi mỗi bạn được mấy ${obj}?`, k, `${2 * k} : 2 = ${k}.`)
      : numberQ(`Có ${5 * k} ${obj} chia đều vào 5 hộp. Hỏi mỗi hộp có mấy ${obj}?`, k, `${5 * k} : 5 = ${k}.`);
  },
};

const soDen1000: Skill = {
  id: 'so_den_1000', subject: 'toan', name: 'Các số trong phạm vi 1000',
  example: 'Số gồm 3 trăm, 4 chục và 5 đơn vị là số nào?',
  generate(d, rng) {
    if (d === 1) {
      const h = randInt(rng, 1, 9), t = randInt(rng, 0, 9), u = randInt(rng, 0, 9);
      return numberQ(`Số gồm ${h} trăm, ${t} chục và ${u} đơn vị là số nào?`, h * 100 + t * 10 + u);
    }
    if (d === 2) {
      const a = randInt(rng, 100, 999);
      const b = pick(rng, [a + randInt(rng, 1, 9), a - randInt(rng, 1, 9), Math.floor(a / 100) * 100 + (a % 10) * 10 + Math.floor((a % 100) / 10)]);
      const bb = Math.min(999, Math.max(100, b));
      return compareQ(String(a), String(bb), a, bb);
    }
    if (pick(rng, [true, false])) {
      const h = randInt(rng, 1, 8);
      return numberQ(`Số liền sau của ${h}99 là số nào?`, (h + 1) * 100);
    }
    const n = randInt(rng, 101, 899);
    return numberQ(`Số tròn trăm liền sau số ${n} là số nào?`, (Math.floor(n / 100) + 1) * 100);
  },
};

const congTru1000: Skill = {
  id: 'cong_tru_1000', subject: 'toan', name: 'Cộng, trừ trong phạm vi 1000',
  example: '300 + 200 = ?',
  generate(d, rng) {
    if (d === 1) {
      const a = randInt(rng, 1, 8), b = randInt(rng, 1, 9 - a);
      return pick(rng, [true, false]) ? numberQ(`${a}00 + ${b}00 = ?`, (a + b) * 100) : numberQ(`${a + b}00 - ${b}00 = ?`, a * 100);
    }
    if (d === 2) {
      const [x, y] = addNoCarry(rng, true);
      const h1 = randInt(rng, 1, 4), h2 = randInt(rng, 1, 4);
      return pick(rng, [true, false])
        ? numberQ(`${h1 * 100 + x} + ${h2 * 100 + y} = ?`, (h1 + h2) * 100 + x + y)
        : numberQ(`${(h1 + h2) * 100 + x + y} - ${h2 * 100 + y} = ?`, h1 * 100 + x);
    }
    const [x, y] = addCarry100(rng, true);
    const h1 = randInt(rng, 1, 4), h2 = randInt(rng, 1, 4);
    return missingAdd(h1 * 100 + x, h2 * 100 + y, rng);
  },
};

const thoiGian: Skill = {
  id: 'thoi_gian', subject: 'toan', name: 'Ngày, giờ, xem đồng hồ',
  example: '1 ngày có ___ giờ',
  generate(d, rng) {
    if (d === 1) {
      const v = randInt(rng, 0, 2);
      if (v === 0) return numberQ('1 ngày có ___ giờ', 24);
      if (v === 1) return numberQ('1 tuần có ___ ngày', 7);
      const h = randInt(rng, 1, 12);
      return numberQ(`Kim ngắn chỉ số ${h}, kim dài chỉ số 12. Đồng hồ chỉ mấy giờ?`, h, `Kim dài chỉ số 12 là giờ đúng: ${h} giờ.`);
    }
    if (d === 2) {
      const days = ['thứ Hai', 'thứ Ba', 'thứ Tư', 'thứ Năm', 'thứ Sáu', 'thứ Bảy', 'Chủ nhật'];
      const i = randInt(rng, 0, 6);
      return choiceQ(rng, `Hôm nay là ${days[i]}. Ngày mai là:`, days[(i + 1) % 7], [days[(i + 6) % 7], days[(i + 2) % 7], days[(i + 3) % 7]]);
    }
    if (pick(rng, [true, false])) {
      const dd = randInt(rng, 1, 23);
      return numberQ(`Thứ Hai tuần này là ngày ${dd}. Thứ Hai tuần sau là ngày bao nhiêu?`, dd + 7, `1 tuần có 7 ngày: ${dd} + 7 = ${dd + 7}.`);
    }
    const h = randInt(rng, 1, 11);
    return choiceQ(rng, `Kim ngắn chỉ giữa số ${h} và số ${h + 1}, kim dài chỉ số 6. Đồng hồ chỉ:`, `${h} giờ 30 phút`,
      [`${h + 1} giờ 30 phút`, `${h} giờ`, `6 giờ ${h} phút`]);
  },
};

export const MATH_SKILLS: Skill[] = [
  soDen100, lienTruocLienSau, soSanh, daySo, thanhPhan, honKem,
  congKhongNho, truKhongNho, congQua10, truQua10, loiVan,
  khoiLuong, doDai, congCoNho, truCoNho,
  nhan25, chia25, soDen1000, congTru1000, thoiGian,
];
