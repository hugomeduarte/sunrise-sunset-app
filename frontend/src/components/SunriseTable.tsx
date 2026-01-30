import type { SunriseSunsetDay } from '../types/sunrise';
import { formatDate } from '../utils/time';
import styles from './SunriseTable.module.css';

interface SunriseTableProps {
  data: SunriseSunsetDay[];
  location: string;
}

export function SunriseTable({ data, location }: SunriseTableProps) {
  return (
    <div className={styles.wrapper}>
      <h3 className={styles.title}>
        Table · {location}
      </h3>
      <div className={styles.scroll}>
        <table className={styles.table}>
          <thead>
            <tr>
              <th>Date</th>
              <th>Sunrise</th>
              <th>Sunset</th>
              <th>Golden hour</th>
            </tr>
          </thead>
          <tbody>
            {data.map((row) => (
              <tr key={row.date}>
                <td>{formatDate(row.date)}</td>
                <td>{row.sunrise || '—'}</td>
                <td>{row.sunset || '—'}</td>
                <td>{row.golden_hour || '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
