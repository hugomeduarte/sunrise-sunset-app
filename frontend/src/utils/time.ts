import { format, parse, isValid } from 'date-fns';

const TIME_PATTERNS = ['HH:mm', 'H:mm', 'HH:mm:ss', 'H:mm:ss', 'h:mm a', 'hh:mm a', 'h:mm:ss a', 'hh:mm:ss a'] as const;

// API often returns "6:10 AM" or "6:10:00 AM" — regex fallback when date-fns fails (e.g. locale)
const TIME_12H_RE = /^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*(AM|PM)$/i;

function parseTimeRegex(s: string): number | null {
  const m = s.match(TIME_12H_RE);
  if (!m) return null;
  let h = parseInt(m[1], 10);
  const min = parseInt(m[2], 10);
  if (m[4].toUpperCase() === 'PM' && h !== 12) h += 12;
  if (m[4].toUpperCase() === 'AM' && h === 12) h = 0;
  return Math.min(23 * 60 + 59, Math.max(0, h * 60 + min));
}

/** Parse time string (e.g. "06:30", "6:30 AM", "8:20 PM", "6:10:00 AM") to minutes since midnight. Returns null for invalid or N/A-like values. */
export function timeToMinutes(value: string): number | null {
  const s = (value || '').trim();
  if (!s || /^(N\/A|-|—)$/i.test(s)) return null;
  // Prefer regex for "6:10 AM" / "6:10:00 AM" so we're not dependent on date-fns locale
  if (/AM|PM/i.test(s)) {
    const parsed = parseTimeRegex(s);
    if (parsed != null) return parsed;
  }
  for (const pattern of TIME_PATTERNS) {
    try {
      const d = parse(s, pattern, new Date());
      if (isValid(d)) return d.getHours() * 60 + d.getMinutes();
    } catch {
      continue;
    }
  }
  return parseTimeRegex(s);
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
