# VTC App Cursor Rules

Public rule pack for building **VTC child apps** (Next.js or static Vite) with [Cursor](https://cursor.com).

**Clone:**

```bash
git clone https://github.com/vtcdotcom/vtc-app-rules.git ~/vtc-app-rules
# or SSH:
# git clone git@github.com:vtcdotcom/vtc-app-rules.git ~/vtc-app-rules
```

**Install into your app** (copies into `.cursor/rules/` — do not symlink, do not commit `.cursor/`):

```bash
~/vtc-app-rules/scripts/copy-cursor-rules.sh /path/to/your-app
```

**New app folder:**

```bash
APPS_ROOT=~/projects ~/vtc-app-rules/scripts/new.sh
```

## Docs

| File | Audience |
|------|----------|
| [EXTERNAL-ONBOARDING.md](EXTERNAL-ONBOARDING.md) | Human developers — setup and workflow |
| [rules/BUILD-CHECKLIST.md](rules/BUILD-CHECKLIST.md) | Human checklist while building |
| [rules/README.md](rules/README.md) | AI assistants — which `.mdc` file to load per task |

**Rule pack version:** see `rules/RULE-PACK-VERSION`.

## Refresh rules in an existing app

```bash
~/vtc-app-rules/scripts/check-rule-pack.sh /path/to/your-app
~/vtc-app-rules/scripts/copy-cursor-rules.sh /path/to/your-app
```

## Contributing

This repository is a published subset of VTC's internal rule pack and is updated by the VTC team. Open an issue for questions or suggestions.

## License

Licensed under the [Apache License 2.0](LICENSE).
