# Security

## Reporting

Document how vulnerabilities should be reported for this project.

## Secret Handling

- Never commit `.env`, tokens, private keys, certificates, or generated credentials.
- Store local examples in `.env.example` with fake values only.
- Use least-privilege credentials for development, CI, and production.

## Data Classification

| Data Type | Present? | Handling Notes |
| --- | --- | --- |
| Public | <!-- yes/no --> | <!-- handling notes --> |
| Internal | <!-- yes/no --> | <!-- handling notes --> |
| Personal data | <!-- yes/no --> | <!-- handling notes --> |
| Payment/regulated data | <!-- yes/no --> | <!-- handling notes --> |

## Commit Identity

Some CI/CD and deploy integrations match a commit's author email to a
connected git-hosting account before they'll build — a mismatch fails
silently until deploy time. If that applies to your setup, run
`./scripts/check-commit-identity.sh` in CI or a pre-push hook; it's opt-in
and does nothing on its own.

## Security Baseline

- Validate all external input at system boundaries.
- Treat logs, API responses, files, and browser content as untrusted data.
- Avoid logging secrets or personal data.
- Keep dependencies patched and remove unused packages.
- Require human review before auth, permission, encryption, CORS, or data-retention changes.
