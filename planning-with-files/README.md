# planning-with-files mixin kit

An sbx **mixin kit** that ships the [planning-with-files](https://github.com/OthmanAdi/planning-with-files)
Claude Code skill (v3.1.3, MIT) into every sandbox it's applied to. The skill implements
Manus-style "filesystem as working memory": before any multi-step task the agent creates
`task_plan.md`, `findings.md`, and `progress.md` in the project, re-reads the plan before
decisions, and logs errors/progress so work survives context loss, `/clear`, and compaction.

## Use

```bash
sbx run claude --kit ./kits/planning-with-files ~/my-project
```

Or add to an already-running sandbox (`--kit` itself is create-time only):

```bash
sbx kit add my-sandbox ./kits/planning-with-files
```

Then inside the sandbox, ask Claude for any multi-step task — it should create the three
planning files. Checkpoint: `ls task_plan.md findings.md progress.md`.

## How it works

- `files/workspace/.claude/skills/planning-with-files/` is injected into the **primary
  workspace** at sandbox creation — the documented mixin pattern for shipping skills
  (sandboxes don't pick up `~/.claude` from the host).
- A startup command restores exec bits on the helper scripts (file injection doesn't
  guarantee them).
- Local dirs need no `kit.allowedSources` change. To load this kit from git/OCI instead,
  allow the source first:
  `sbx settings set kit.allowedSources '["docker.io/","github.com/"]'`

## What's vendored

`SKILL.md` (v3.1.3), `examples.md`, `reference.md`, `LICENSE` (MIT), `templates/`
(task_plan / findings / progress), `scripts/` (init-session, check-complete,
resolve-plan-dir, set-active-plan, attest-plan — bash + PowerShell — and
session-catchup.py). Snapshot of upstream `master`, fetched 2026-07-08.

Refresh the vendored copy: `./vendor.sh` (runs on the **host**, needs git).

## Notes & caveats

- **The skill registers hooks** (UserPromptSubmit, PreToolUse, PostToolUse, Stop,
  PreCompact) via SKILL.md frontmatter — they activate for sessions in the workspace.
  That's the point (plan re-reading, completion gating), but know it's not a passive
  prompt: it changes agent behavior.
- Upstream's SKILL.md references four hook scripts (`inject-plan.sh`, `gate-stop.sh`,
  `ledger-append.sh`, `ledger-summary.sh`) that don't exist in the upstream `scripts/`
  dir. The hooks check for file existence and fail soft, so plan-injection silently
  no-ops with this file set. Upstream issue, not a vendoring error.
- The skill writes planning files into the workspace — since the workspace is the one
  host-shared surface, plans persist on your machine after `sbx rm`. That's the feature.
- Kits are experimental; re-validate with `sbx kit validate ./kits/planning-with-files`
  after sbx upgrades.
