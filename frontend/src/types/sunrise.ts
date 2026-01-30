export interface SunriseSunsetDay {
  date: string;
  sunrise: string;
  sunset: string;
  golden_hour: string;
}

export interface SunriseSunsetPagination {
  page: number;
  total_pages: number;
  total: number;
  limit: number;
  has_next: boolean;
  has_previous: boolean;
}

export interface SunriseSunsetResponse {
  location: string;
  start_date: string;
  end_date: string;
  source: string;
  pagination: SunriseSunsetPagination;
  data: SunriseSunsetDay[];
}

export interface SunriseSunsetParams {
  location: string;
  start_date: string;
  end_date: string;
  limit?: number;
  page?: number;
}
