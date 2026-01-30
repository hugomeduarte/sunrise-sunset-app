import { useState } from 'react';
import { format, parseISO, isValid, subDays } from 'date-fns';
import type { SunriseSunsetParams } from '../types/sunrise';
import styles from './SearchForm.module.css';

const today = format(new Date(), 'yyyy-MM-dd');
const defaultStart = format(subDays(new Date(), 7), 'yyyy-MM-dd');

interface SearchFormProps {
  onSubmit: (params: SunriseSunsetParams) => void;
  isLoading?: boolean;
}

function isInvalidDateRange(start: string, end: string): boolean {
  try {
    const s = parseISO(start);
    const e = parseISO(end);
    return !isValid(s) || !isValid(e) || s > e;
  } catch {
    return true;
  }
}

function getValidParams(
  location: string,
  startDate: string,
  endDate: string
): SunriseSunsetParams | null {
  const loc = location.trim();
  if (!loc) return null;
  const start = startDate.trim();
  const end = endDate.trim();
  if (!start || !end) return null;
  try {
    const startD = parseISO(start);
    const endD = parseISO(end);
    if (!isValid(startD) || !isValid(endD) || startD > endD) return null;
    return { location: loc, start_date: start, end_date: end };
  } catch {
    return null;
  }
}

export function SearchForm({ onSubmit, isLoading }: SearchFormProps) {
  const [location, setLocation] = useState('');
  const [startDate, setStartDate] = useState(defaultStart);
  const [endDate, setEndDate] = useState(today);
  const [touched, setTouched] = useState(false);

  const invalidRange = isInvalidDateRange(startDate, endDate);

  const handleSubmit = (e: { preventDefault(): void }) => {
    e.preventDefault();
    setTouched(true);
    const params = getValidParams(location, startDate, endDate);
    if (params) onSubmit(params);
  };

  const showLocationError = touched && !location.trim();
  const showRangeError = touched && invalidRange;

  return (
    <form className={styles.form} onSubmit={handleSubmit} noValidate>
      <div className={styles.field}>
        <label htmlFor="location">Location</label>
        <input
          id="location"
          type="text"
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          placeholder="e.g. Lisbon, London, Berlin"
          autoComplete="off"
          aria-invalid={showLocationError}
          aria-describedby={showLocationError ? 'location-error' : undefined}
        />
        {showLocationError && (
          <span id="location-error" className={styles.error}>
            Enter a location
          </span>
        )}
      </div>

      <div className={styles.row}>
        <div className={styles.field}>
          <label htmlFor="start_date">Start date</label>
          <input
            id="start_date"
            type="date"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
            max={endDate || undefined}
            aria-invalid={!!showRangeError}
          />
        </div>
        <div className={styles.field}>
          <label htmlFor="end_date">End date</label>
          <input
            id="end_date"
            type="date"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
            min={startDate || undefined}
            aria-invalid={!!showRangeError}
          />
        </div>
      </div>

      {showRangeError && (
        <p className={styles.rangeError} role="alert">
          Start date must be before or equal to end date.
        </p>
      )}

      <button
        type="submit"
        className={styles.submit}
        disabled={isLoading || !location.trim() || invalidRange}
      >
        {isLoading ? 'Loading…' : 'Get sunrise & sunset'}
      </button>
    </form>
  );
}
