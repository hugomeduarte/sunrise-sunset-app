import { useState, useCallback } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { SearchForm } from './components/SearchForm';
import { SunriseChart } from './components/SunriseChart';
import { SunriseTable } from './components/SunriseTable';
import { PaginationControls } from './components/PaginationControls';
import { LoadingSpinner } from './components/LoadingSpinner';
import { ErrorMessage } from './components/ErrorMessage';
import { useSunriseSunset } from './hooks/useSunriseSunset';
import type { SunriseSunsetParams } from './types/sunrise';
import styles from './App.module.css';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

function SunriseApp() {
  const [params, setParams] = useState<SunriseSunsetParams | null>(null);
  const { data, isLoading, isFetching, error, refetch } = useSunriseSunset(params);

  const handleSubmit = useCallback((p: SunriseSunsetParams) => {
    setParams({ ...p, page: 1 });
  }, []);

  const hasSearched = params !== null;
  const loading = isLoading || isFetching;
  const hasData = !!data?.data?.length;

  return (
    <div className={styles.app}>
      <header className={styles.header}>
        <h1 className={styles.title}>Sunrise & Sunset</h1>
        <p className={styles.subtitle}>
          Historical sunrise, sunset, and golden hour for any location
        </p>
      </header>

      <section className={styles.formSection} aria-label="Search">
        <SearchForm onSubmit={handleSubmit} isLoading={loading} />
      </section>

      {error && (
        <div className={styles.alertSection}>
          <ErrorMessage error={error} onRetry={() => refetch()} />
        </div>
      )}

      {loading && hasSearched && !data && (
        <div className={styles.loadingSection}>
          <LoadingSpinner />
        </div>
      )}

      {hasData && data && (
        <>
          {data.pagination && data.pagination.total > 0 && (
            <section className={styles.paginationSection} aria-label="Pagination">
              <PaginationControls
                pagination={data.pagination}
                onPrevious={() =>
                  setParams((prev) =>
                    prev ? { ...prev, page: Math.max(1, data.pagination.page - 1) } : prev
                  )
                }
                onNext={() =>
                  setParams((prev) =>
                    prev ? { ...prev, page: data.pagination.page + 1 } : prev
                  )
                }
                isLoading={loading}
              />
            </section>
          )}
          <section className={styles.dataSection} aria-label="Chart and table">
            <div className={styles.chartSection}>
              <SunriseChart
                data={data.data}
                location={data.location}
              />
            </div>
            <div className={styles.tableSection}>
              <SunriseTable
                data={data.data}
                location={data.location}
              />
            </div>
          </section>
        </>
      )}

      {hasSearched && !loading && !error && !hasData && (
        <div className={styles.empty} role="status">
          <p>No data for this location and date range.</p>
          <p className={styles.emptyHint}>
            Try another location (e.g. Lisbon, London, Berlin) or different dates.
          </p>
        </div>
      )}
    </div>
  );
}

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <SunriseApp />
    </QueryClientProvider>
  );
}
