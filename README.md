# Coffee Shops API

A Rails API that returns the 3 closest coffee shops to a given location, sourced from a remote CSV.

**Data source:** [Agilefreaks test CSV](https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv)

---

## Requirements

- Ruby 3.x (see `.ruby-version`)
- Bundler
- Docker (optional)

---

## Setup

### Local

```bash
bundle install
bin/rails server
```

### Docker

```bash
docker compose up --build
```

The app will be available at `http://localhost:3000`.

---

## Architecture

```
Request
  │
  ▼
┌──────────────────────────────┐
│  CoffeeShopsController       │  Validates x/y params
│  GET /api/v1/coffee_shops    │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│  CoffeeShopFinder            │  Orchestrator
└──────┬───────────┬───────────┘
       │           │
       ▼           ▼
┌─────────────┐ ┌────────────────────┐
│  CsvFetcher │ │ DistanceCalculator │
│  + CsvParser│ │ Euclidean distance │
└─────────────┘ └────────────────────┘
       │
       ▼
  Remote CSV
  (cached 1h)
```

---

## API Reference

### `GET /api/v1/coffee_shops`

Returns the 3 closest coffee shops to the given coordinates, sorted closest to farthest.

#### Parameters

| Parameter | Type   | Required | Description         |
|-----------|--------|----------|---------------------|
| `x`       | Float  | Yes      | X coordinate        |
| `y`       | Float  | Yes      | Y coordinate        |

#### Example

```bash
curl "http://localhost:3000/api/v1/coffee_shops?x=47.6&y=-122.4"
```

```json
{
  "data": [
    {
      "id": "1",
      "type": "coffee_shop",
      "attributes": {
        "name": "Starbucks Seattle2",
        "x": 47.5869,
        "y": -122.3368,
        "distance": 0.0645
      }
    },
    {
      "id": "2",
      "type": "coffee_shop",
      "attributes": {
        "name": "Starbucks Seattle",
        "x": 47.5809,
        "y": -122.316,
        "distance": 0.0861
      }
    },
    {
      "id": "3",
      "type": "coffee_shop",
      "attributes": {
        "name": "Starbucks SF",
        "x": 37.5209,
        "y": -122.334,
        "distance": 10.0793
      }
    }
  ]
}
```

#### Error Responses

| Status | Cause                            | `errors[0].status` |
|--------|----------------------------------|--------------------|
| 422    | Missing or non-numeric `x`/`y`   | `"422"`            |
| 503    | Remote CSV could not be fetched  | `"503"`            |

Error bodies follow JSON API Specification format:

```json
{
  "errors": [
    {
      "status": "422",
      "title": "Invalid Parameters",
      "detail": "x and y must be valid numbers"
    }
  ]
}
```

---

## Running Tests

```bash
bundle exec rspec
```

---

## Lint

```bash
bundle exec rubocop
bundle exec rubocop -a  # auto-correct safe offenses
```

---

## Trade-offs and Assumptions

- **No database** — coffee shop data is fetched from the remote CSV on every request. The data set is small and the problem statement requires no persistence.
- **Euclidean distance** — coordinates are treated as a flat plane (`Math.sqrt((x2-x1)**2 + (y2-y1)**2).round(4)`). This is appropriate for the exercise but would need the Haversine formula for real geographic distances.
- **In-memory caching** — CSV responses are cached for 1 hour via `Rails.cache` (memory store). Cache is not shared across processes and is lost on restart. A production system would use Redis or Memcached.
- **No authentication** — the API is open. A production system would add API keys or OAuth.
- **JSON API Specification** — responses use the `jsonapi-serializer` gem. This adds structure but increases payload size compared to minimal JSON.
- **Malformed row handling** — CSV rows with missing or non-numeric coordinates are silently skipped with a log warning. No error is raised to the caller.
- **Network resilience** — `CsvFetcher` has a 5-second timeout and raises a typed `FetchError` on failure, mapped to a 503. No retry logic is implemented.
- **No pagination** — the endpoint always returns exactly 3 results. Pagination would be needed if requirements changed.
- **Duplicate query params** — Rails takes the last value when a param appears multiple times (e.g. `x=47.6&x=50.0` uses `50.0`). We accept this default rather than rejecting ambiguous input, since the challenge spec assumes well-formed requests.
- **Performance at scale** — the current approach iterates all rows and sorts to find the 3 closest, which is O(n log n). This is fine for the ~100-row CSV in the challenge. At 100k+ rows, we'd consider a spatial index (k-d tree, R-tree) or a database with PostGIS to avoid a full scan on every request.
