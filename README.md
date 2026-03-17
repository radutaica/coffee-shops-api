# Coffee Shops API

A Rails API that returns the 3 closest coffee shops to a given location, sourced from a remote CSV.

**Data source:** [Agilefreaks test CSV](https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv)

---

## Requirements

- Ruby 3.x (see `.ruby-version`)
- Bundler

---

## Setup

```bash
bundle install
bin/rails server
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
        "x": 47.5788,
        "y": 122.3974,
        "distance": 244.8294
      }
    },
    {
      "id": "2",
      "type": "coffee_shop",
      "attributes": {
        "name": "Starbucks Seattle",
        "x": 47.5869,
        "y": 122.4236,
        "distance": 244.8311
      }
    },
    {
      "id": "3",
      "type": "coffee_shop",
      "attributes": {
        "name": "Starbucks SF",
        "x": 37.5841,
        "y": 122.4011,
        "distance": 244.8441
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

## Design Decisions

- **No database** — coffee shop data is fetched from the remote CSV on every request. The data set is small and the problem statement requires no persistence.
- **Euclidean distance** — coordinates are treated as a flat plane: `Math.sqrt((x2-x1)**2 + (y2-y1)**2).round(4)`.
- **JSON API Specification** — responses use the `jsonapi-serializer` gem rather than hand-rolled JSON.
- **Malformed row handling** — CSV rows with fewer than 3 columns, or non-numeric X/Y values, are silently skipped.
- **Network resilience** — `CsvFetcher` has a 5-second timeout and raises a typed `FetchError` for any network or HTTP error, which the controller maps to a 503.
