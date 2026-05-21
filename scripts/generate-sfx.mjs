#!/usr/bin/env node
// Renaissance Architect Academy — batch SFX generation.
//
// Reads scripts/sfx-manifest.json, POSTs each entry to the Cloudflare Worker's
// /sfx route, and writes the returned mp3 bytes directly into the iOS bundle
// folder (RenaissanceArchitectAcademy/<filename>).
//
// This is a DEV-TIME tool. The game never calls /sfx at runtime — once a
// generated mp3 is added to Xcode and shipped in the bundle, AVAudioPlayer
// reads it from disk and the API is irrelevant.
//
// Usage:
//   PROXY_TOKEN=... node scripts/generate-sfx.mjs
//   PROXY_TOKEN=... node scripts/generate-sfx.mjs --only city_ambient.mp3
//   node scripts/generate-sfx.mjs --dry-run
//
// Requires Node 20+ (uses built-in fetch).

import { readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const MANIFEST_PATH = resolve(__dirname, "sfx-manifest.json");
const OUTPUT_DIR = resolve(REPO_ROOT, "RenaissanceArchitectAcademy");
const WORKER_URL = "https://raa-api.pollak.workers.dev/sfx";

const args = process.argv.slice(2);
const dryRun = args.includes("--dry-run");
const onlyIdx = args.indexOf("--only");
const onlyFilename = onlyIdx >= 0 ? args[onlyIdx + 1] : null;

const proxyToken = process.env.PROXY_TOKEN;
if (!dryRun && !proxyToken) {
  console.error("ERROR: PROXY_TOKEN env var is required.");
  console.error("Run: PROXY_TOKEN=<token> node scripts/generate-sfx.mjs");
  process.exit(1);
}

const manifest = JSON.parse(await readFile(MANIFEST_PATH, "utf8"));
const jobs = onlyFilename
  ? manifest.filter((entry) => entry.filename === onlyFilename)
  : manifest;

if (onlyFilename && jobs.length === 0) {
  console.error(`ERROR: no manifest entry matches --only ${onlyFilename}`);
  process.exit(1);
}

console.log(`SFX generation — ${jobs.length} file(s)${dryRun ? " (dry run)" : ""}`);
console.log(`Output: ${OUTPUT_DIR}\n`);

let succeeded = 0;
let failed = 0;

for (const job of jobs) {
  const { filename, prompt, duration_seconds, prompt_influence } = job;
  console.log(`→ ${filename}  (${duration_seconds}s, influence ${prompt_influence})`);
  console.log(`  prompt: ${prompt.slice(0, 80)}${prompt.length > 80 ? "..." : ""}`);

  if (dryRun) {
    console.log("  [dry run — skipping API call]\n");
    continue;
  }

  try {
    const response = await fetch(WORKER_URL, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "X-Proxy-Token": proxyToken,
      },
      body: JSON.stringify({
        text: prompt,
        duration_seconds,
        prompt_influence,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`  ✗ HTTP ${response.status}: ${errorText}\n`);
      failed += 1;
      continue;
    }

    const bytes = new Uint8Array(await response.arrayBuffer());
    const outputPath = resolve(OUTPUT_DIR, filename);
    await writeFile(outputPath, bytes);
    console.log(`  ✓ saved ${bytes.length.toLocaleString()} bytes\n`);
    succeeded += 1;
  } catch (err) {
    console.error(`  ✗ ${err.message}\n`);
    failed += 1;
  }
}

console.log(`Done — ${succeeded} succeeded, ${failed} failed`);
if (succeeded > 0) {
  console.log(`\nNext: drag the new files into Xcode → Add to target "RenaissanceArchitectAcademy".`);
}
process.exit(failed > 0 ? 1 : 0);
