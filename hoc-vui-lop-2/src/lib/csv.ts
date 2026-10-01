import Papa from 'papaparse';

export type SheetRow = Record<string, string>;

export function toCsv(rows: Array<Record<string, unknown>>, columns: Array<[key: string, header: string]>): string {
  const data = rows.map((r) => columns.map(([k]) => {
    const v = r[k];
    if (v === null || v === undefined) return '';
    if (Array.isArray(v)) return v.join('|');
    return String(v);
  }));
  return Papa.unparse({ fields: columns.map(([, h]) => h), data });
}

export function downloadText(filename: string, content: string, mime = 'text/csv;charset=utf-8'): void {
  // BOM để Excel mở tiếng Việt không lỗi font.
  const blob = new Blob(['\ufeff' + content], { type: mime });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

/** Đọc file CSV hoặc Excel (.xlsx/.xls) thành mảng dòng {tên cột: giá trị}. */
export async function readSpreadsheet(file: File): Promise<SheetRow[]> {
  const name = file.name.toLowerCase();
  if (name.endsWith('.xlsx') || name.endsWith('.xls') || name.endsWith('.ods')) {
    const XLSX = await import('xlsx');
    // Ô ngày mặc định hiển thị kiểu Mỹ m/d/yy: ép về ngày/tháng/năm để không đọc nhầm ngày sinh.
    const wb = XLSX.read(await file.arrayBuffer(), { type: 'array', cellDates: true, dateNF: 'dd/mm/yyyy' });
    const sheet = wb.Sheets[wb.SheetNames[0]];
    if (!sheet) return [];
    const rows = XLSX.utils.sheet_to_json<Record<string, unknown>>(sheet, { defval: '', raw: false, dateNF: 'dd/mm/yyyy' });
    return rows.map((r) => Object.fromEntries(Object.entries(r).map(([k, v]) => [k, String(v ?? '')])));
  }
  const text = await file.text();
  const res = Papa.parse<SheetRow>(text.replace(/^\ufeff/, ''), { header: true, skipEmptyLines: 'greedy' });
  return res.data;
}
