# Pages repo — mitchills.github.io

Public publishing repo. Every file here becomes a live URL. **Public by default** —
anyone with the link can read it unless it's encrypted.

## Folder rules

- `public-encrypted/` — source HTML I edit. Auto-encrypted into `public/` on every commit.
- `public/` — encrypted output. **Auto-generated — never edit by hand.**
- `index.html` and other root files — public, unencrypted (landing page etc.).
- `.env` — master encryption secret. **Gitignored. Never commit or print it.**

## Encryption workflow

- Put anything sensitive in `public-encrypted/`. A pre-commit hook encrypts it automatically (StatiCrypt, AES-256).
- Each file gets a unique password (master secret + file path). One client's password never unlocks another's report.
- Retrieve passwords with `bash scripts/passwords.sh`.
- Share URL and password **separately** (email the link, DM the password).

## What to ENCRYPT (put in public-encrypted/)

- Performance reports — revenue, ROAS, spend, conversion rates
- Internal/team dashboards
- Executive or board updates
- Strategy documents and audit findings
- Proposals with pricing
- Campaign briefs with competitive intel
- Anything I wouldn't want a competitor or the public to see

## What to leave PUBLIC (root or unencrypted folders)

- My own portfolio
- Marketing materials for Mastered Marketing's services
- Public case studies (sensitive numbers redacted)
- Training / how-to content
- Landing pages meant for everyone

## When in doubt → encrypt.
