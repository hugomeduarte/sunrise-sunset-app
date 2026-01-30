import { useState, useCallback } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { SearchForm } from './components/SearchForm';
import { SunriseChart } from './components/SunriseChart';
import { SunriseTable } from './components/SunriseTable';
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
    setParams(p);
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
          <section className={styles.chartSection} aria-label="Chart">
            <SunriseChart
              data={data.data}
              location={data.location}
            />
          </section>
          <section className={styles.tableSection} aria-label="Data table">
            <SunriseTable
              data={data.data}
              location={data.location}
            />
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
