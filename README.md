# Sunrise & Sunset App

App para consultar horários de nascer e pôr do sol (e golden hour) por local e intervalo de datas. Backend em **Rails 8 (Ruby)**, frontend em **React + TypeScript** (Vite).

---

## Como correr

### Opção rápida (tudo de uma vez)

```bash
./start.sh
```

- Instala dependências do backend e frontend
- Cria e migra a base de dados (SQLite)
- Arranca o backend em **http://localhost:3000**
- Arranca o frontend em **http://localhost:5173**

Abre **http://localhost:5173** no browser.

### Manual

**Backend**

```bash
cd backend
bundle install
bin/rails db:create db:migrate
bin/rails server
```

**Frontend** (noutro terminal)

```bash
cd frontend
pnpm install
pnpm dev
```

Depois abre **http://localhost:5173**.

---

## O que esperar

1. **Formulário**: local (ex.: Lisbon, London, Berlin), data início e fim. Botão "Get sunrise & sunset".
2. **Paginação**: "Showing 1–31 of 50" com Previous / Next. Chart e tabela mostram a **mesma página** de dados.
3. **Chart**: linhas de Sunrise, Sunset e Golden hour para a página atual.
4. **Tabela**: mesmos dados em tabela (data, sunrise, sunset, golden hour).

**Locais disponíveis**: Lisbon, London, Berlin, Madrid, Paris, Porto, Amsterdam, Tokyo, Sydney, New York, North Pole, South Pole, Longyearbyen, Alert, etc. (lista hardcoded no backend — ver secção abaixo).

**Limites**: intervalo máximo **365 dias**; datas em `YYYY-MM-DD`.

---

## Stack

| Camada      | Tecnologia |
|------------|------------|
| Frontend   | React 19, TypeScript, Vite, TanStack Query (React Query), Recharts, date-fns |
| Backend    | Rails 8, Ruby, SQLite |
| API externa | [SunriseSunset.io](https://api.sunrisesunset.io/json) (lat/lng + datas) |

---

## Decisões e o que está feito

### Frontend

- **React Query (TanStack Query)**  
  Centraliza o estado dos pedidos: loading, erro, dados. **Cache** por `queryKey` (location + datas + page + limit): o mesmo pedido não é repetido; usa cache (ex.: 5 min de `staleTime`). Não é preciso repetir estado em vários sítios.

- **Retry**  
  Configurado para **1 retry** (`retry: 1`): se o primeiro pedido falhar, faz mais um (total 2 tentativas).

- **Proxy**  
  O frontend faz pedidos a `/api/...`. O Vite faz proxy para `http://localhost:3000` (ou `VITE_API_PROXY_TARGET`). Assim o browser não expõe o URL do backend; útil para segurança e para evitar CORS em desenvolvimento.

- **Paginação**  
  **Page-based** (página 1, 2, 3…) na tabela e no chart, para ser simples e legível. Para muitos dados, **cursor-based** no chart (ex.: arrastar e carregar mais) seria mais eficiente — fica como melhoria futura.

### Backend

- **Geocoder**  
  A API externa exige **coordenadas** (lat/lng). Em vez de um geocoder real (ex.: Nominatim), há uma lista **hardcoded** de cidades e coordenadas (`LocationGeocoder`). Dá para testar o fluxo no projeto (Lisbon, London, Berlin, polos, etc.) sem depender de serviços externos de geocoding.

- **Intervalo máximo 365 dias**  
  Validação no repositório: "Date range cannot exceed 365 days".

- **Pedidos à API só do que falta (na página atual)**  
  A BD guarda uma linha por par `(location_key, date)` (tabela `sunrise_sunset_entries`). Para cada pedido, o repositório devolve **uma página** de datas (ex.: dias 1–31). Para essa página:
  1. Lê da BD o que já existe para esse local nesse intervalo de datas (ex.: dias 1–31).
  2. Calcula quais dias desse intervalo faltam (`missing_date_ranges`).
  3. Chama a API **só para esses dias em falta** (agrupados em intervalos consecutivos para menos chamadas).
  4. Grava na BD e devolve a resposta.

  Exemplo: pedido que devolve a página com dias 1–31; na BD já existem 30 desses dias → **1 chamada à API** para o 1 dia em falta.

- **Repository + Services + lib**  
  Controller só trata HTTP; repositório orquestra (datas, geocoder, BD, API, resposta); serviços fazem uma coisa cada (geocoder, HTTP à API); `lib/pagination` é reutilizável. Ver `backend/ARCHITECTURE.md` para o desenho.

---

## Possíveis melhorias

- **Redis como cache**  
  Dados históricos mudam pouco. Uma camada Redis em frente à BD (ler/gravar por chave tipo `location_key:date`) poderia reduzir latência (ex.: ~1 ms) e carga na BD. Depende se Redis for aceitável no ambiente (entrevista/deploy).

- **Cursor no chart**  
  Para muitos pontos, paginação por cursor no chart (ex.: arrastar e carregar mais dados a partir de um cursor) evita offset grande e mantém o chart fluido. Aqui usou-se paginação por página em chart e tabela para simplificar.

- **Crescimento da BD**  
  Não há TTL nem limpeza: cada par (local, data) que se busca fica na tabela. Com muitos locais e intervalos a tabela cresce; em produção poderia fazer sentido TTL ou limpeza periódica.

---

## Estrutura relevante

```
sunrise-sunset-app/
├── start.sh                 # Arranque backend + frontend
├── backend/
│   ├── app/
│   │   ├── controllers/api/ # HTTP, params, render JSON
│   │   ├── repositories/    # Regra "dados sunrise para local + datas"
│   │   ├── services/       # Geocoder (nome→coords), API externa
│   │   └── models/         # SunriseSunsetEntry (BD)
│   ├── lib/
│   │   └── pagination.rb   # Paginação reutilizável (slice, meta)
│   └── ARCHITECTURE.md     # Diagrama controller → repo → services
└── frontend/
    ├── src/
    │   ├── api/            # fetchSunriseSunset, client (proxy → /api)
    │   ├── hooks/          # useSunriseSunset (React Query)
    │   ├── components/    # SearchForm, Chart, Table, Pagination
    │   └── utils/          # time (parse "6:10 AM", formatDate)
    └── vite.config.ts      # proxy /api → backend
```

---

## Testes

**Backend**

```bash
cd backend && bundle exec rails test
```

**Frontend**

```bash
cd frontend && pnpm run lint
```

---

## Variáveis de ambiente (frontend)

| Variável | Descrição |
|----------|-----------|
| `VITE_API_BASE_URL` | Base URL da API. Vazio = pedidos relativos (proxy em dev). |
| `VITE_API_PROXY_TARGET` | Alvo do proxy do Vite para `/api`. Default: `http://localhost:3000`. |

Ver `frontend/.env.example` se existir.
