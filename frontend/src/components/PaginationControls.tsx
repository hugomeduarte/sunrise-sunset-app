import type { SunriseSunsetPagination } from '../types/sunrise';
import styles from './PaginationControls.module.css';

interface PaginationControlsProps {
  pagination: SunriseSunsetPagination;
  onPrevious: () => void;
  onNext: () => void;
  isLoading?: boolean;
}

export function PaginationControls({
  pagination,
  onPrevious,
  onNext,
  isLoading = false,
}: PaginationControlsProps) {
  const { total, limit, page, has_previous, has_next } = pagination;
  const from = total === 0 ? 0 : (page - 1) * limit + 1;
  const to = Math.min(page * limit, total);

  return (
    <nav
      className={styles.wrapper}
      aria-label="Pagination"
    >
      <p className={styles.info} role="status">
        Showing {from}–{to} of {total}
      </p>
      <div className={styles.buttons}>
        <button
          type="button"
          onClick={onPrevious}
          disabled={!has_previous || isLoading}
          className={styles.button}
          aria-label="Previous page"
        >
          Previous
        </button>
        <button
          type="button"
          onClick={onNext}
          disabled={!has_next || isLoading}
          className={styles.button}
          aria-label="Next page"
        >
          Next
        </button>
      </div>
    </nav>
  );
}
