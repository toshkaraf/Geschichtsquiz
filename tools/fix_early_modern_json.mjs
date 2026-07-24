#!/usr/bin/env node
/**
 * Fix broken JSON in early_modern files: German „..." uses ASCII " as closer.
 * Replaces „WORD" with „WORD" (U+201D) when ASCII quote appears inside a JSON string value.
 */
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const dir = path.join(path.dirname(fileURLToPath(import.meta.url)), '../lib/data/Fragen/Detailed')

function fixGermanQuotesInJsonText(text) {
  // „ ... " — ASCII closing quote inside value breaks JSON; use U+201D.
  return text.replace(/„([^"\n]+)"/g, (_, inner) => `„${inner}\u201D`)
}

function validateAndWrite(filePath) {
  const raw = fs.readFileSync(filePath, 'utf8')
  try {
    JSON.parse(raw)
    console.log(`${path.basename(filePath)}: already valid (${JSON.parse(raw).length} questions)`)
    return true
  } catch {
    const fixed = fixGermanQuotesInJsonText(raw)
    const data = JSON.parse(fixed)
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n', 'utf8')
    console.log(`${path.basename(filePath)}: fixed and wrote ${data.length} questions`)
    return true
  }
}

for (const name of fs.readdirSync(dir).filter((f) => f.startsWith('early_modern'))) {
  validateAndWrite(path.join(dir, name))
}
