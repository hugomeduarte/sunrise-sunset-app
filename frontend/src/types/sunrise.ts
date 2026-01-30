export interface SunriseSunsetDay {
  date: string;
  sunrise: string;
  sunset: string;
  golden_hour: string;
}

export interface SunriseSunsetResponse {
  location: string;
  start_date: string;
  end_date: string;
  data: SunriseSunsetDay[];
}

export interface SunriseSunsetParams {
  location: string;
  start_date: string;
  end_date: string;
}
