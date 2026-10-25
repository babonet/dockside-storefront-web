# dockside-storefront-web

Customer-facing storefront for **Dockside Market**.

| | |
|---|---|
| Owner | Checkout team |
| Tier | 2 |
| Depends on | `dockside-checkout-api` |

## Routes

| Method | Path | Description |
|---|---|---|
| `GET` | `/health` | Liveness and version |
| `GET` | `/` | Home page |
| `GET` | `/api/featured` | Featured products |

## Run locally

```bash
npm start
npm test
npm run smoke
```

## Delivery pipeline

`ci.yml` (PR tests), `deploy.yml` (rollout + post-deploy smoke test, raises an `alert` issue on failure), `rollback.yml` and `followup.yml` (dispatched by Port).

> Part of the Dockside Market demo for Port's **self-healing incidents** solution. The production rollout is simulated inside the GitHub Actions runner.
