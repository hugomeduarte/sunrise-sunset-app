import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import type { SunriseSunsetDay } from '../types/sunrise';
import { timeToMinutes, minutesToTime, formatDate } from '../utils/time';
import styles from './SunriseChart.module.css';

interface SunriseChartProps {
  data: SunriseSunsetDay[];
  location: string;
}

interface ChartPoint {
  date: string;
  dateLabel: string;
  sunrise: number | null;
  sunset: number | null;
  sunriseLabel: string;
  sunsetLabel: string;
  golden_hour: string;
}

function toChartPoints(data: SunriseSunsetDay[]): ChartPoint[] {
  return data.map((d) => {
    const sm = timeToMinutes(d.sunrise);
    const ssm = timeToMinutes(d.sunset);
    return {
      date: d.date,
      dateLabel: formatDate(d.date),
      sunrise: sm,
      sunset: ssm,
      sunriseLabel: d.sunrise,
      sunsetLabel: d.sunset,
      golden_hour: d.golden_hour,
    };
  });
}

function formatTick(minutes: number): string {
  return minutesToTime(minutes);
}

export function SunriseChart({ data, location }: SunriseChartProps) {
  const points = toChartPoints(data);
  const allMinutes = points.flatMap((p) =>
    [p.sunrise, p.sunset].filter((m): m is number => m != null)
  );
  const minM = allMinutes.length ? Math.min(...allMinutes) : 0;
  const maxM = allMinutes.length ? Math.max(...allMinutes) : 24 * 60;
  const padding = 60;
  const yMin = Math.max(0, minM - padding);
  const yMax = Math.min(24 * 60, maxM + padding);

  return (
    <div className={styles.wrapper}>
      <h3 className={styles.title}>
        Sunrise & sunset · {location}
      </h3>
      <div className={styles.chart}>
        <ResponsiveContainer width="100%" height={320}>
          <LineChart
            data={points}
            margin={{ top: 8, right: 16, left: 8, bottom: 8 }}
          >
            <CartesianGrid
              strokeDasharray="3 3"
              stroke="var(--color-grid)"
              vertical={false}
            />
            <XAxis
              dataKey="dateLabel"
              tick={{ fill: 'var(--color-muted)', fontSize: 12 }}
              tickLine={false}
              axisLine={{ stroke: 'var(--color-border)' }}
            />
            <YAxis
              domain={[yMin, yMax]}
              tickFormatter={formatTick}
              tick={{ fill: 'var(--color-muted)', fontSize: 12 }}
              tickLine={false}
              axisLine={{ stroke: 'var(--color-border)' }}
              width={48}
            />
            <Tooltip
              contentStyle={{
                background: 'var(--color-surface)',
                border: '1px solid var(--color-border)',
                borderRadius: 'var(--radius-sm)',
              }}
              labelStyle={{ color: 'var(--color-fg)' }}
              labelFormatter={(_, payload) =>
                (payload?.[0]?.payload as ChartPoint)?.dateLabel ?? ''
              }
              formatter={(value) =>
                typeof value === 'number' ? formatTick(value) : '—'
              }
            />
            <Legend
              wrapperStyle={{ fontSize: '0.85rem' }}
              formatter={(value) => (value === 'sunrise' ? 'Sunrise' : 'Sunset')}
            />
            <Line
              type="monotone"
              dataKey="sunrise"
              name="sunrise"
              stroke="var(--color-sunrise)"
              strokeWidth={2}
              dot={{ r: 3, fill: 'var(--color-sunrise)' }}
              connectNulls={false}
            />
            <Line
              type="monotone"
              dataKey="sunset"
              name="sunset"
              stroke="var(--color-sunset)"
              strokeWidth={2}
              dot={{ r: 3, fill: 'var(--color-sunset)' }}
              connectNulls={false}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
      <p className={styles.hint}>
        Golden hour is shown in the table below.
      </p>
    </div>
  );
}
