import { choiceQ, numberQ, pick, randInt, shuffle, textQ, type Difficulty, type Rng, type Skill } from './core.ts';

// [cụm từ có chỗ trống, đáp án]
type Blank = [string, string];

function spellingSkill(id: string, name: string, pair: [string, string], rule: string, items: Blank[]): Skill {
  const [a, b] = pair;
  const fill = (item: Blank, letter: string) => item[0].replace('___', letter);
  const other = (letter: string) => (letter === a ? b : a);
  return {
    id, subject: 'tieng_viet', name,
    example: `Điền ${a} hoặc ${b}: ${items[0][0]}`,
    generate(d: Difficulty, rng: Rng) {
      const item = pick(rng, items);
      if (d === 1) {
        const others = shuffle(rng, items.filter((x) => x !== item)).slice(0, 2);
        return choiceQ(rng, 'Từ nào viết đúng chính tả?', fill(item, item[1]),
          [fill(item, other(item[1])), ...others.map((x) => fill(x, other(x[1])))], rule);
      }
      if (d === 2) {
        return textQ(`Điền "${a}" hoặc "${b}" vào chỗ trống:  ${item[0]}`, item[1], null, `Viết đúng là: ${fill(item, item[1])}. ${rule}`);
      }
      const rights = shuffle(rng, items.filter((x) => x !== item)).slice(0, 3);
      return choiceQ(rng, 'Từ nào viết SAI chính tả?', fill(item, other(item[1])), rights.map((x) => fill(x, x[1])),
        `Viết đúng là: ${fill(item, item[1])}. ${rule}`);
    },
  };
}

const chinhTaCK = spellingSkill('chinh_ta_c_k', 'Chính tả: c hay k', ['c', 'k'],
  'Viết k trước i, e, ê; viết c trước các chữ còn lại.', [
    ['cái ___éo', 'k'], ['cái ___ẹo', 'k'], ['con ___iến', 'k'], ['đeo ___ính', 'k'], ['___ể chuyện', 'k'],
    ['que ___em', 'k'], ['dòng ___ênh', 'k'], ['cái ___ìm', 'k'], ['___ì diệu', 'k'],
    ['con ___á', 'c'], ['___ây xanh', 'c'], ['___ô giáo', 'c'], ['con ___ua', 'c'], ['___ổng trường', 'c'],
    ['___ốc nước', 'c'], ['___ầu thang', 'c'], ['quả ___am', 'c'], ['lá ___ờ', 'c'], ['hoa ___úc', 'c'], ['bãi ___ỏ', 'c'],
  ]);

const chinhTaGGh = spellingSkill('chinh_ta_g_gh', 'Chính tả: g hay gh', ['g', 'gh'],
  'Viết gh trước i, e, ê; viết g trước các chữ còn lại.', [
    ['cái ___ế', 'gh'], ['___i nhớ', 'gh'], ['con ___ẹ', 'gh'], ['___ép hình', 'gh'], ['thác ___ềnh', 'gh'],
    ['cái ___im', 'gh'], ['___é thăm', 'gh'], ['con ___à', 'g'], ['bàn ___ỗ', 'g'], ['hạt ___ạo', 'g'],
    ['cái ___ối', 'g'], ['con ___ấu', 'g'], ['cái ___ương', 'g'], ['củ ___ừng', 'g'], ['___ọn gàng', 'g'],
    ['cây ___ậy', 'g'], ['___õ cửa', 'g'], ['con ___ấu bông', 'g'],
  ]);

const chinhTaNgNgh = spellingSkill('chinh_ta_ng_ngh', 'Chính tả: ng hay ngh', ['ng', 'ngh'],
  'Viết ngh trước i, e, ê; viết ng trước các chữ còn lại.', [
    ['con ___é', 'ngh'], ['___ỉ ngơi', 'ngh'], ['lắng ___e', 'ngh'], ['suy ___ĩ', 'ngh'], ['___ề nông', 'ngh'],
    ['một ___ìn', 'ngh'], ['___iêng đầu', 'ngh'], ['___à voi', 'ng'], ['___õ nhỏ', 'ng'], ['con ___ựa', 'ng'],
    ['đi ___ủ', 'ng'], ['con ___an', 'ng'], ['bắp ___ô', 'ng'], ['___ón tay', 'ng'], ['___ày mai', 'ng'],
    ['kẹo ___ọt', 'ng'], ['con ___ỗng', 'ng'],
  ]);

const THINGS = ['bàn học', 'quyển vở', 'cây bút', 'con mèo', 'cái cặp', 'ngôi nhà', 'bông hoa', 'quả bóng', 'cô giáo', 'học sinh', 'cái bảng', 'cây bàng', 'con chó', 'đôi dép'];
const ACTIONS = ['chạy', 'nhảy dây', 'đọc sách', 'viết bài', 'hát', 'múa', 'quét nhà', 'tưới cây', 'học bài', 'vẽ tranh', 'đá bóng', 'bơi', 'nấu cơm', 'rửa bát'];
const TRAITS = ['xanh biếc', 'đỏ tươi', 'cao', 'thấp', 'chăm chỉ', 'ngoan ngoãn', 'hiền lành', 'xinh đẹp', 'to lớn', 'nhỏ xíu', 'vui vẻ', 'dịu dàng', 'thơm ngát', 'mềm mại'];

const phanLoaiTu: Skill = {
  id: 'tu_su_vat_hoat_dong_dac_diem', subject: 'tieng_viet', name: 'Từ chỉ sự vật, hoạt động, đặc điểm',
  example: 'Từ nào chỉ hoạt động?',
  generate(d, rng) {
    const groups: Array<[string, string[], string[]]> = [
      ['sự vật', THINGS, [...ACTIONS, ...TRAITS]],
      ['hoạt động', ACTIONS, [...THINGS, ...TRAITS]],
      ['đặc điểm', TRAITS, [...THINGS, ...ACTIONS]],
    ];
    if (d === 3 && pick(rng, [true, false])) {
      const [label, own, rest] = pick(rng, groups);
      return choiceQ(rng, `Từ nào KHÔNG chỉ ${label}?`, pick(rng, rest), shuffle(rng, own).slice(0, 3),
        `Các từ còn lại đều chỉ ${label}.`);
    }
    const [label, own, rest] = groups[d === 1 ? 0 : d === 2 ? 1 : 2];
    const answer = pick(rng, own);
    return choiceQ(rng, `Từ nào chỉ ${label}?`, answer, shuffle(rng, rest).slice(0, 3), `"${answer}" là từ chỉ ${label}.`);
  },
};

const ALPHABET = ['a', 'ă', 'â', 'b', 'c', 'd', 'đ', 'e', 'ê', 'g', 'h', 'i', 'k', 'l', 'm', 'n', 'o', 'ô', 'ơ', 'p', 'q', 'r', 's', 't', 'u', 'ư', 'v', 'x', 'y'];

const bangChuCai: Skill = {
  id: 'bang_chu_cai', subject: 'tieng_viet', name: 'Bảng chữ cái tiếng Việt',
  example: 'Chữ cái đứng ngay sau chữ b là chữ nào?',
  generate(d, rng) {
    if (d === 3 && randInt(rng, 0, 4) === 0) {
      return numberQ('Bảng chữ cái tiếng Việt có bao nhiêu chữ cái?', 29, 'Bảng chữ cái tiếng Việt có 29 chữ cái.');
    }
    const i = randInt(rng, 1, ALPHABET.length - 2);
    const after = d !== 2;
    const target = ALPHABET[i];
    const answer = after ? ALPHABET[i + 1] : ALPHABET[i - 1];
    const text = `Chữ cái đứng ngay ${after ? 'sau' : 'trước'} chữ "${target}" là chữ nào?`;
    const expl = `Thứ tự: ${ALPHABET[i - 1]}, ${target}, ${ALPHABET[i + 1]}.`;
    if (d === 3) return textQ(text, answer, null, expl);
    const near = ALPHABET.filter((x) => x !== answer && x !== target);
    return choiceQ(rng, text, answer, shuffle(rng, near).slice(0, 3), expl);
  },
};

const STATEMENTS = ['Em là học sinh lớp 2', 'Mẹ em là cô giáo', 'Hôm nay trời nắng đẹp', 'Con mèo nằm trên ghế', 'Bố em đi làm từ sáng sớm', 'Chúng em chơi đá cầu', 'Bà kể chuyện cổ tích cho em nghe', 'Sân trường có cây bàng rất to'];
const QUESTIONS = ['Bạn tên là gì', 'Nhà bạn ở đâu', 'Hôm nay bạn có vui không', 'Bạn học lớp mấy', 'Ai đang hát thế', 'Con mèo đâu rồi', 'Bao giờ chúng mình đi chơi', 'Bạn thích con vật nào nhất'];
const EXCLAIMS = ['Ôi, bông hoa đẹp quá', 'A, mẹ về rồi', 'Hoan hô, đội mình thắng rồi', 'Chà, chiếc cặp mới đẹp quá', 'Ồ, tuyết rơi kìa', 'Trời ơi, con diều bay cao quá'];

const INTRO = ['Em là học sinh lớp 2A', 'Mẹ em là bác sĩ', 'Đây là cô giáo của em', 'Bạn Nam là lớp trưởng'];
const ACTION_S = ['Mẹ đang nấu cơm', 'Các bạn đang nhảy dây', 'Bố tưới cây ngoài vườn', 'Em đang đọc truyện'];
const TRAIT_S = ['Bông hoa hồng rất đẹp', 'Chú mèo nhà em rất ngoan', 'Bầu trời hôm nay trong xanh', 'Cô giáo em rất hiền'];

const dauCau: Skill = {
  id: 'dau_cau_kieu_cau', subject: 'tieng_viet', name: 'Dấu câu và kiểu câu',
  example: 'Điền dấu câu thích hợp: Bạn tên là gì ___',
  generate(d, rng) {
    const signQ = (sentence: string, sign: string, why: string) => ({
      ...choiceQ(rng, `Chọn dấu câu thích hợp:  ${sentence} ___`, sign, ['.', '?', '!'].filter((x) => x !== sign), why, true),
      options: ['.', '?', '!'],
    });
    if (d === 1) {
      return pick(rng, [true, false])
        ? signQ(pick(rng, STATEMENTS), '.', 'Câu kể, câu giới thiệu kết thúc bằng dấu chấm.')
        : signQ(pick(rng, QUESTIONS), '?', 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.');
    }
    if (d === 2) {
      const v = randInt(rng, 0, 2);
      if (v === 0) return signQ(pick(rng, EXCLAIMS), '!', 'Câu bộc lộ cảm xúc (vui, ngạc nhiên...) kết thúc bằng dấu chấm than.');
      if (v === 1) return signQ(pick(rng, QUESTIONS), '?', 'Câu dùng để hỏi kết thúc bằng dấu chấm hỏi.');
      return signQ(pick(rng, STATEMENTS), '.', 'Câu kể kết thúc bằng dấu chấm.');
    }
    const kinds: Array<[string, string[], string[]]> = [
      ['câu giới thiệu (Ai là gì?)', INTRO, [...ACTION_S, ...TRAIT_S]],
      ['câu nêu hoạt động (Ai làm gì?)', ACTION_S, [...INTRO, ...TRAIT_S]],
      ['câu nêu đặc điểm (Ai thế nào?)', TRAIT_S, [...INTRO, ...ACTION_S]],
      ['câu hỏi', QUESTIONS.map((q) => q + '?'), [...STATEMENTS, ...INTRO].map((s) => s + '.')],
    ];
    const [label, own, rest] = pick(rng, kinds);
    const answer = pick(rng, own);
    const fmt = (s: string) => (/[.?!]$/.test(s) ? s : s + '.');
    return choiceQ(rng, `Câu nào là ${label}?`, fmt(answer), shuffle(rng, rest).slice(0, 3).map(fmt));
  },
};

// [từ, từ trái nghĩa, các cách viết khác được chấp nhận]
const ANTONYMS: Array<[string, string, string[]]> = [
  ['cao', 'thấp', []], ['to', 'nhỏ', ['bé']], ['dài', 'ngắn', []], ['nóng', 'lạnh', []], ['vui', 'buồn', []],
  ['sạch', 'bẩn', []], ['nhanh', 'chậm', []], ['khỏe', 'yếu', []], ['trắng', 'đen', []], ['mới', 'cũ', []],
  ['ngày', 'đêm', []], ['trên', 'dưới', []], ['sáng', 'tối', []], ['đúng', 'sai', []], ['béo', 'gầy', []],
  ['già', 'trẻ', []], ['xa', 'gần', []], ['cứng', 'mềm', []], ['ngọt', 'đắng', []], ['chăm chỉ', 'lười biếng', ['lười']],
];

const tuTraiNghia: Skill = {
  id: 'tu_trai_nghia', subject: 'tieng_viet', name: 'Từ trái nghĩa',
  example: 'Từ trái nghĩa với "cao" là:',
  generate(d, rng) {
    const [w, ant, alt] = pick(rng, ANTONYMS);
    const flip = pick(rng, [true, false]);
    const word = flip && alt.length === 0 ? ant : w;
    const answer = word === w ? ant : w;
    if (d === 1) {
      const others = shuffle(rng, ANTONYMS.filter((x) => x[0] !== w)).slice(0, 3).map((x) => pick(rng, [x[0], x[1]]));
      return choiceQ(rng, `Từ trái nghĩa với "${word}" là:`, answer, others, `"${word}" và "${answer}" có nghĩa trái ngược nhau.`);
    }
    if (d === 2) {
      const accepted = word === w ? alt : answer === 'khỏe' ? ['khoẻ'] : null;
      return textQ(`Viết từ trái nghĩa với từ "${word}":`, answer, accepted, `"${word}" và "${answer}" có nghĩa trái ngược nhau.`);
    }
    const wrong = shuffle(rng, ANTONYMS.filter((x) => x[0] !== w)).slice(0, 3);
    const distractors = wrong.map((x, i) => `${x[0]} – ${wrong[(i + 1) % 3][1]}`);
    return choiceQ(rng, 'Cặp từ nào là cặp từ trái nghĩa?', `${w} – ${ant}`, distractors);
  },
};

// [câu, đáp án, lựa chọn sai]
const FILLS: Array<[string, string, string[]]> = [
  ['Con mèo đang ___ trên ghế.', 'nằm', ['bơi', 'bay', 'hót']],
  ['Chú chim đang ___ trên cành cây.', 'hót', ['bơi', 'sủa', 'gáy']],
  ['Con cá đang ___ dưới nước.', 'bơi', ['bay', 'chạy', 'nhảy dây']],
  ['Con gà trống ___ ò ó o mỗi sáng.', 'gáy', ['sủa', 'hót', 'bơi']],
  ['Con chó ___ gâu gâu.', 'sủa', ['gáy', 'hót', 'kêu meo meo']],
  ['Em dùng ___ để cắt giấy.', 'kéo', ['bút', 'thước', 'tẩy']],
  ['Em dùng ___ để viết bài.', 'bút', ['kéo', 'tẩy', 'hồ dán']],
  ['Mẹ đang ___ cơm trong bếp.', 'nấu', ['đọc', 'viết', 'bay']],
  ['Buổi sáng, ông mặt trời ___ ở đằng đông.', 'mọc', ['lặn', 'rơi', 'chạy']],
  ['Bầu trời hôm nay rất ___.', 'xanh', ['ngọt', 'chăm chỉ', 'mặn']],
  ['Bạn Lan rất ___ nên được cô khen.', 'chăm chỉ', ['lười biếng', 'tròn', 'mặn']],
  ['Quả chanh có vị ___.', 'chua', ['ngọt lịm', 'cay', 'mặn']],
  ['Đường có vị ___.', 'ngọt', ['chua', 'mặn', 'đắng']],
  ['Muối có vị ___.', 'mặn', ['ngọt', 'chua', 'cay']],
  ['Mùa hè thời tiết rất ___.', 'nóng', ['lạnh', 'ngọt', 'mặn']],
  ['Mùa đông thời tiết rất ___.', 'lạnh', ['nóng bức', 'mặn', 'ngọt']],
  ['Cô giáo đang ___ bài trên bảng.', 'giảng', ['ngủ', 'bơi', 'hót']],
];
const TEXT_FILLS = ['Con cá đang ___ dưới nước.', 'Con chó ___ gâu gâu.', 'Con gà trống ___ ò ó o mỗi sáng.', 'Quả chanh có vị ___.', 'Đường có vị ___.', 'Muối có vị ___.', 'Em dùng ___ để cắt giấy.'];

const dienTu: Skill = {
  id: 'dien_tu_vao_cau', subject: 'tieng_viet', name: 'Chọn từ điền vào câu',
  example: 'Con mèo đang ___ trên ghế.',
  generate(d, rng) {
    if (d === 3) {
      const target = pick(rng, TEXT_FILLS);
      const [s, ans] = FILLS.find((f) => f[0] === target)!;
      return textQ(`Điền từ thích hợp vào chỗ trống:  ${s}`, ans, null, s.replace('___', ans));
    }
    const pool = d === 1 ? FILLS.slice(0, 8) : FILLS.slice(5);
    const [s, ans, wrong] = pick(rng, pool);
    return choiceQ(rng, `Chọn từ thích hợp điền vào chỗ trống:  ${s}`, ans, wrong, s.replace('___', ans));
  },
};

export const VIETNAMESE_SKILLS: Skill[] = [bangChuCai, chinhTaCK, chinhTaGGh, chinhTaNgNgh, phanLoaiTu, dauCau, tuTraiNghia, dienTu];
