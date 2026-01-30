import { useQuery, keepPreviousData } from '@tanstack/react-query';
import { fetchSunriseSunset } from '../api/sunrise';
import type { SunriseSunsetParams } from '../types/sunrise';

const QUERY_KEY = ['sunrise-sunset'] as const;

export function useSunriseSunset(params: SunriseSunsetParams | null) {
  return useQuery({
    queryKey: [...QUERY_KEY, params],
    queryFn: () => fetchSunriseSunset(params!),
    enabled: !!params && !!params.location.trim() && !!params.start_date && !!params.end_date,
    placeholderData: keepPreviousData,
    staleTime: 5 * 60 * 1000,
  });
}
