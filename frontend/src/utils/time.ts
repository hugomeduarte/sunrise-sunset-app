import { format, parse, isValid } from 'date-fns';

/** Parse "HH:mm" to minutes since midnight. Returns null for invalid or N/A-like values. */
export function timeToMinutes(value: string): number | null {
  const s = (value || '').trim().toUpperCase();
  if (!s || s === 'N/A' || s === '-' || s === '—') return null;
  try {
    const d = parse(s, 'HH:mm', new Date());
    if (!isValid(d)) return null;
    return d.getHours() * 60 + d.getMinutes();
  } catch {
    return null;
  }
}

/** Format minutes since midnight to "HH:mm" */
export function minutesToTime(minutes: number): string {
  const h = Math.floor(minutes / 60) % 24;
  const m = Math.floor(minutes % 60);
  return format(new Date(2000, 0, 1, h, m), 'HH:mm');
}

export function formatDate(value: string): string {
  try {
    const d = new Date(value);
    return isValid(d) ? format(d, 'dd MMM yyyy') : value;
  } catch {
    return value;
  }
}
