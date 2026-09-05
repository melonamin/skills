---
name: wrangler
description: Use Cloudflare Wrangler to develop, validate, deploy, or manage Workers and their resources. Load for Wrangler commands or configuration; prefer the installed project CLI and matching schema. Do not load for unrelated deployments or install/upgrade Wrangler merely to inspect a project.
---

# Wrangler

Inspect the project's package manager, installed Wrangler version, scripts, configuration, and environment. Prefer its project-local command and node_modules/wrangler/config-schema.json. Use the configured compatibility date; changing it or upgrading dependencies is a separate behavior change.

Check the installed command's --help and relevant official documentation at https://developers.cloudflare.com/workers/wrangler/ before relying on version-sensitive flags. The guides below are reference examples, not instructions to execute every command or replace an existing config. Inspect current account, resource, and environment before mutations. Deploy, delete, or alter remote data only within the requested scope. A dry run is not deployment.

Do not install packages to answer a read-only question. If implementation requires a missing CLI, use the repository's package-manager convention and an appropriate compatible version. Read only the relevant guide; do not load the entire command catalog.

## Task guides

- [Introduction](guide-introduction.md)
- [Retrieval Sources](guide-retrieval-sources.md)
- [Locate the project CLI](guide-first-check-if-wrangler-is-installed-and-if-not-install-it.md)
- [Key Guidelines](guide-key-guidelines.md)
- [Quick Start: New Worker](guide-quick-start-new-worker.md)
- [Quick Reference: Core Commands](guide-quick-reference-core-commands.md)
- [Configuration (wrangler.jsonc)](guide-configuration-wrangler-jsonc.md)
- [Local Development](guide-local-development.md)
- [Deployment](guide-deployment.md)
- [KV (Key-Value Store)](guide-kv-key-value-store.md)
- [R2 (Object Storage)](guide-r2-object-storage.md)
- [D1 (SQL Database)](guide-d1-sql-database.md)
- [Vectorize (Vector Database)](guide-vectorize-vector-database.md)
- [Hyperdrive (Database Accelerator)](guide-hyperdrive-database-accelerator.md)
- [Workers AI](guide-workers-ai.md)
- [Queues](guide-queues.md)
- [Containers](guide-containers.md)
- [Workflows](guide-workflows.md)
- [Pipelines](guide-pipelines.md)
- [Secrets Store](guide-secrets-store.md)
- [Pages (Frontend Deployment)](guide-pages-frontend-deployment.md)
- [Observability](guide-observability.md)
- [Testing](guide-testing.md)
- [Troubleshooting](guide-troubleshooting.md)
- [Best Practices](guide-best-practices.md)
