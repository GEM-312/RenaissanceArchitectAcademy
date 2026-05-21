#!/usr/bin/env node
// Renaissance Architect Academy — batch music generation.
//
// Reads scripts/music-manifest.json, POSTs each entry to the Cloudflare Worker's
// /music route (ElevenLabs Music Compose), and writes the returned mp3 bytes
// directly into the iOS bundle folder.
//
// Same dev-time-only model as generate-sfx.mjs — bundled mp3s are played from
// disk at runtime; the worker is never hit in production.
//
// Usage:
//   PROXY_TOKEN=... node scripts/generate-music.mjs
//   PROXY_TOKEN=... node scripts/generate-music.mjs --only music_city.mp3
//   node scripts/generate-music.mjs --dry-run
//
// Requires Node 20+ (uses built-in fetch).
//
// Note: music generation is slow (60–180s per track). The script uses no
// timeout on fetch — let it run.

import { readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const MANIFEST_PATH = resolve(__dirname, "music-manifest.json");
const OUTPUT_DIR = resolve(REPO_ROOT, "RenaissanceArchitectAcademy");
const WORKER_URL = "https://raa-api.pollak.workers.dev/music?output_format=mp3_44100_128";

const args = process.argv.slice(2);
const dryRun = args.includes("--dry-run");
const onlyIdx = args.indexOf("--only");
const onlyFilename = onlyIdx >= 0 ? args[onlyIdx + 1] : null;

const proxyToken = process.env.PROXY_TOKEN;
if (!dryRun && !proxyToken) {
  console.error("ERROR: PROXY_TOKEN env var is required.");
  console.error("Run: PROXY_TOKEN=<token> node scripts/generate-music.mjs");
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

console.log(`Music generation — ${jobs.length} track(s)${dryRun ? " (dry run)" : ""}`);
console.log(`Output: ${OUTPUT_DIR}`);
console.log(`Note: each track takes 60–180s. Be patient.\n`);

let succeeded = 0;
let failed = 0;

for (const job of jobs) {
  const { filename, prompt, music_length_ms, force_instrumental, model_id } = job;
  const seconds = Math.round(music_length_ms / 1000);
  console.log(`→ ${filename}  (${seconds}s, instrumental=${force_instrumental ?? false})`);
  console.log(`  prompt: ${prompt.slice(0, 80)}${prompt.length > 80 ? "..." : ""}`);

  if (dryRun) {
    console.log("  [dry run — skipping API call]\n");
    continue;
  }

  const start = Date.now();
  try {
    const requestBody = { prompt };
    if (typeof music_length_ms === "number") requestBody.music_length_ms = music_length_ms;
    if (typeof force_instrumental === "boolean") requestBody.force_instrumental = force_instrumental;
    if (typeof model_id === "string") requestBody.model_id = model_id;

    const response = await fetch(WORKER_URL, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "X-Proxy-Token": proxyToken,
      },
      body: JSON.stringify(requestBody),
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
    const elapsed = ((Date.now() - start) / 1000).toFixed(1);
    console.log(`  ✓ saved ${bytes.length.toLocaleString()} bytes in ${elapsed}s\n`);
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
