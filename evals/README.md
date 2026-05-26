# Bird-chat prompt evals

Evaluates the bird companion's system prompt against a fixed test set, two ways:

1. **Code-based graders** (deterministic, free) — non-empty, length budget, no
   markdown, mentions the building context, stays clean.
2. **Model-based grader** — Claude **Sonnet 4.6** judges each reply on accuracy,
   age-appropriateness, tone, on-topic behavior, and follow-up (1–5 + rationale),
   plus a `behavedCorrectly` flag and `redFlags`.

It calls the **real Cloudflare Worker** `/chat` endpoint, so it measures the exact
prod path (prompt caching, the real system prompt). The candidate model and
temperature mirror `ClaudeService` (`claude-haiku-4-5`, `0.7`).

## Run

The Worker authenticates this script via the shared proxy token (`X-Proxy-Token`
header — `verifyAuth` Path B). **Export it yourself; never paste it on the command
line** (Claude Code would persist an inlined secret in settings):

```bash
export RAA_PROXY_TOKEN=$(cat /path/to/your/token-file)   # the Worker PROXY_TOKEN
node evals/run-evals.mjs
```

Output prints a summary and writes `evals/results/<timestamp>.{json,md}`
(the `results/` folder is gitignored).

## Files

| File | Purpose |
|---|---|
| `testset.json` | The graded cases (on-topic, off-topic→redirect, inappropriate→refuse, edge, hallucination traps). |
| `run-evals.mjs` | Orchestrator: prompt builder (ported from `AIService.swift`), code graders, Sonnet judge, report writer. |

## Keeping it honest

`birdSystemPrompt()` in `run-evals.mjs` is a **verbatim port** of
`BirdContext.systemPrompt` in `AIService.swift`. If you change the Swift prompt,
update the port and re-run so the eval reflects what actually ships.

## Adding cases

Append to `testset.json`. Each case needs `context`, `question`, `expectBehavior`
(`answer` | `redirect` | `refuse`), and `tags`. Add `"allowLong": true` for math
walk-throughs that legitimately run past a few sentences.
