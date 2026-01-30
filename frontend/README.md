# Sunrise & Sunset — Frontend

React + TypeScript frontend for the Sunrise Sunset app. Uses **React Query** for server state (caching, deduplication, loading/error), **Recharts** for the chart, and **date-fns** for dates.

## Run

```bash
pnpm install
pnpm dev
```

The dev server runs at `http://localhost:5173` and proxies `/api` to the backend (default `http://localhost:9292`). Set `VITE_API_PROXY_TARGET` if your Ruby API runs elsewhere.

## Build

```bash
pnpm build
pnpm preview   # serve dist
```

For production, configure `VITE_API_BASE_URL` if the API is on another origin.

## API contract

The app expects a backend that serves:

- **GET** `/api/sunrise_sunset?location=<name>&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD`
- **Response** (JSON):

```json
{
  "location": "Lisbon",
  "start_date": "2025-08-01",
  "end_date": "2025-08-31",
  "data": [
    {
      "date": "2025-08-01",
      "sunrise": "06:35",
      "sunset": "20:45",
      "golden_hour": "20:15"
    }
  ]
}
```

- **Errors**: `4xx`/`5xx` with optional `{ "error": "message" }` in the body.

## Env

| Variable | Description |
|----------|-------------|
| `VITE_API_BASE_URL` | API base URL for production (optional; relative `/api` used if unset). |
| `VITE_API_PROXY_TARGET` | Proxy target in dev (default `http://localhost:9292`). |

See `.env.example`.
