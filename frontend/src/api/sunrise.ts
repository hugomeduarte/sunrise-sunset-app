import { apiRequest } from './client';
import type {
  SunriseSunsetParams,
  SunriseSunsetResponse,
} from '../types/sunrise';

function buildQuery(params: SunriseSunsetParams): string {
  const q = new URLSearchParams({
    location: params.location.trim(),
    start_date: params.start_date,
    end_date: params.end_date,
  });
  if (params.limit != null) q.set('limit', String(params.limit));
  if (params.page != null) q.set('page', String(params.page));
  return q.toString();
}

export async function fetchSunriseSunset(
  params: SunriseSunsetParams
): Promise<SunriseSunsetResponse> {
  const query = buildQuery(params);
  return apiRequest<SunriseSunsetResponse>(
    `/api/sunrise_sunset?${query}`
  );
}
