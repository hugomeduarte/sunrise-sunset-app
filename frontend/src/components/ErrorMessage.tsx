import { ApiError } from '../api/client';
import styles from './ErrorMessage.module.css';

interface ErrorMessageProps {
  error: Error | null;
  onRetry?: () => void;
}

export function ErrorMessage({ error, onRetry }: ErrorMessageProps) {
  if (!error) return null;

  const message = error instanceof ApiError
    ? error.message
    : error instanceof Error
      ? error.message
      : String(error);

  return (
    <div className={styles.wrapper} role="alert">
      <span className={styles.icon} aria-hidden>⚠</span>
      <p className={styles.message}>{message}</p>
      {onRetry && (
        <button type="button" className={styles.retry} onClick={onRetry}>
          Try again
        </button>
      )}
    </div>
  );
}
