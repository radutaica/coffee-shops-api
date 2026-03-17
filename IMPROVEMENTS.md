# Improvement Roadmap

Tracks all planned improvements. Each milestone is checked off in the same commit that closes it.

## GitFlow

- [x] Merge `feature/coffee-shops-endpoint` → `develop` (baseline established)

## Milestones

- [x] **M1** — Service Architecture Refactor (`feature/service-architecture`)
  - Extract `CoffeeShop` PORO from `CsvFetcher` struct
  - Split `CsvParser` out of `CsvFetcher` as dedicated service
  - Add `CoffeeShopFinder` orchestrator
  - Simplify controller to delegate to `CoffeeShopFinder`

- [ ] **M2** — Configuration & Caching (`feature/caching-and-config`)
  - Make CSV URL configurable via `ENV['COFFEE_SHOPS_CSV_URL']`
  - Cache CSV response in `Rails.cache` with 1-hour TTL
  - Configure `memory_store` for dev/test

- [ ] **M3** — CSV Robustness (`feature/csv-robustness`)
  - Strip whitespace from CSV values before parsing
  - Detect and skip CSV header row automatically
  - Log warnings for each skipped malformed row

- [ ] **M4** — JSON:API Full Compliance (`feature/jsonapi-compliance`)
  - Set `Content-Type: application/vnd.api+json` on all responses

- [ ] **M5** — DevOps & Tooling (`feature/devops-tooling`)
  - Add `docker-compose.yml` for one-command local setup
  - Add `simplecov` with 95% coverage threshold
  - Add `rubocop-rspec` for spec style enforcement
  - Add `/health` endpoint

- [ ] **M6** — Documentation (`feature/documentation`)
  - Update README with Docker setup and architecture diagram
  - Add trade-offs and assumptions section
  - Fix incorrect Y values in example response

- [ ] **Final PR** — `develop` → `main`
