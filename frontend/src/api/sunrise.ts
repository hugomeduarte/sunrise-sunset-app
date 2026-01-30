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
