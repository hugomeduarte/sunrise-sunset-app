const API_BASE = import.meta.env.VITE_API_BASE_URL ?? '';

export const config = {
  apiBaseUrl: API_BASE || (typeof window !== 'undefined' ? '' : ''),
} as const;
