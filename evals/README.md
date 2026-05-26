# Bird-chat prompt evals

Two complementary harnesses, both routing through the **real Cloudflare Worker
`/chat`** (so they test the prod path) and both authenticating with the shared
proxy token via `RAA_PROXY_TOKEN` — never inline it on the command line.

| Harness | Dataset | Grading | Output |
|---|---|---|---|
| `run-evals.mjs` (Node) | fixed `testset.json` (18 hand-written cases) | code-based checks **+** Sonnet judge (5 axes) | `results/<ts>.{json,md}` |
| `bird_eval.py` (Python) | **auto-generated** by Sonnet from a task spec | Sonnet judge 1–10 + mandatory criteria → auto-fail | `results/<ts>.{json,html}` + `dataset-<ts>.json` |

`bird_eval.py` is the Anthropic-course `PromptEvaluator` framework
(`AnthropicCourse/002_prompting_completed.ipynb`) adapted to this project: it
auto-builds a diverse dataset, runs the bird's real system prompt (Haiku, temp
0.0), and grades each reply with a strict Sonnet judge that forces a score ≤ 3 on
any safety/hallucination/off-topic violation. Zero pip dependencies (stdlib only).

```bash
export RAA_PROXY_TOKEN=$(cat /path/to/your/token-file)
python3 evals/bird_eval.py        # auto-dataset + model-graded HTML report
node    evals/run-evals.mjs        # fixed cases + code checks + judge
```

---

## run-evals.mjs

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
