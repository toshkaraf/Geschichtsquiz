#!/usr/bin/env node
/**
 * Replaces legacy German ASCII digraphs (ae, oe, ue) with ä, ö, ü in quiz JSON.
 * Protects common words where "ue"/"oe" are not umlaut encodings.
 */
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const dataDir = path.join(__dirname, '..', 'lib', 'data', 'Fragen', 'Detailed')

const PROTECT_PHRASES = [
  /\b(feuer|feuers|neue|neuen|neues|neuer|neuere|neuem|teuer|teuerste|teuersten|abenteuer|abenteuern|abenteuerlichem|quer|querstra|quelle|quellen|quellenkritik|quellenkritisch|quellenlage|steuer|steuern|steuerbasis|steuersystem|steuerstrukturen|steuerbefreiungen|steuerorganisation|steuerstabilit|bauer|bauern|mauer|mauern|stadtmauer|stadtmauern|festungsmauer|verteidigungsmauern|virtuell|virtuellen|sexuelle|sexueller|dauer|dauern|dauerte|dauerten|dauerhaft|dauerhafte|dauerinstitution|ausdauer|ausdauerleistung|frauen|frauenfest|frauenk|frauenrollen|ehefrauen|homosexuellen|naturvorgaenge|naturerklaerung|urinationsteuer|einfaelle|aufrechtzuerhalten|aufzuerstehen|anzuerkennen|wiederaufzubauen|zuschauer|zuschauern|zuschauerinnen|zuschauerplatz|zufaelligkeit|zuerst|zunaechst|zurueck|berquert|berquerte|berquerten|berquerung|durchqueren|durchquerte|statuetten|statuette|statuen|elfenbeinstatue|elfenbeinstatuette|tempelstatuen|tempelstatue|tterstatuen|tterstatue|heldenstatuen|freiheitsstatue|holzstatue|kalksteinstatue|weihestatuen|bildhauer|bildhauerei|bildhauers|augenbraue|augenbrauen|blauem|blaue|blueten|ausbauen|bauen|megabauer|schoepfung|schoener|weiss|weisse|rituelle|rituellem|rituelles|ritueller|rituellen|rituell|spirituelle|spiritueller|spirituellen|spirituell|Statue|statue)\b/gi,
  /\b(poesie|poeten|poetisch|poetische|poetischen|poetischer|poetik|poetica|liebespoesie)\b/gi,
  /\b(true|blue|queue|technique|techniques)\b/gi,
]

let protectCounter = 0
const protectMap = new Map()

function protectPhrases(s) {
  let out = s
  protectCounter = 0
  protectMap.clear()
  for (const re of PROTECT_PHRASES) {
    out = out.replace(re, (m) => {
      const token = `\uE000${protectCounter++}\uE001`
      protectMap.set(token, m)
      return token
    })
  }
  return out
}

function unprotectPhrases(s) {
  let out = s
  for (const [token, original] of protectMap) {
    out = out.split(token).join(original)
  }
  return out
}

/** Swiss «ss» spellings and «gross» → «groß» where appropriate. */
function fixGrossAndStrasse(s) {
  let o = s
  o = o.replace(/strasse\b/g, 'straße').replace(/Strasse\b/g, 'Straße')
  o = o.replace(/\b(G|g)ross(es|en|em|er|e)\b/g, (_, g, e) => {
    const p = g === 'G' ? 'Gro' : 'gro'
    const suf = { e: 'ße', es: 'ßes', en: 'ßen', em: 'ßem', er: 'ßer' }
    return p + suf[e]
  })
  o = o.replace(/\b(G|g)ross\b/g, (_, g) => (g === 'G' ? 'Gro' : 'gro') + 'ß')
  o = o.replace(
    /\b(G|g)ross(?=[a-zA-ZäöüÄÖÜ])(?!i)/g,
    (_, g) => (g === 'G' ? 'Gro' : 'gro') + 'ß',
  )
  return o
}

function fixGermanDigraphs(s) {
  let o = protectPhrases(s)

  o = o.replace(/\bhiess\b/g, 'hieß').replace(/\bHiess\b/g, 'Hieß')

  o = o.replace(/ae/g, 'ä').replace(/Ae/g, 'Ä').replace(/AE/g, 'Ä')
  o = o.replace(/oe/g, 'ö').replace(/Oe/g, 'Ö').replace(/OE/g, 'Ö')

  o = o.replace(/(?<![aeiouäöüAEIOUÄÖÜqQ])ue/g, 'ü')
  o = o.replace(/(?<![aeiouäöüAEIOUÄÖÜqQ])Ue/g, 'Ü')
  o = o.replace(/(?<![aeiouäöüAEIOUÄÖÜqQ])UE/g, 'Ü')

  o = unprotectPhrases(o)

  const POST = [
    [/\bpösie\b/gi, 'poesie'],
    [/\bpötisch\b/gi, 'poetisch'],
    [/\bpötische\b/gi, 'poetische'],
    [/\bpötischen\b/gi, 'poetischen'],
    [/\bpötischer\b/gi, 'poetischer'],
    [/\bpötik\b/gi, 'poetik'],
    [/\bpötica\b/gi, 'poetica'],
    [/\bPöteten\b/g, 'Poeten'],
    [/\bpöteten\b/g, 'poeten'],
    [/ritüllem\b/g, 'rituellem'],
    [/ritülles\b/g, 'rituelles'],
    [/ritülle\b/g, 'rituelle'],
    [/ritüller\b/g, 'ritueller'],
    [/ritüllen\b/g, 'rituellen'],
    [/ritüll\b/g, 'rituell'],
    [/spiritüllen\b/g, 'spirituellen'],
    [/spiritüller\b/g, 'spiritueller'],
    [/spiritüll\b/g, 'spirituell'],
    [/Statütten/g, 'Statuetten'],
    [/statütten/g, 'statuetten'],
    [/Statün/g, 'Statuen'],
    [/statün/g, 'statuen'],
    [/Statü/g, 'Statue'],
    [/statü/g, 'statue'],
  ]
  for (const [re, rep] of POST) {
    o = o.replace(re, rep)
  }
  o = fixGrossAndStrasse(o)
  return o
}

function processQuestion(item) {
  const o = { ...item }
  for (const k of ['question_de', 'explanation_de', 'correct_answer_de']) {
    if (typeof o[k] === 'string') o[k] = fixGermanDigraphs(o[k])
  }
  if (Array.isArray(o.wrong_answers_de)) {
    o.wrong_answers_de = o.wrong_answers_de.map((s) =>
      typeof s === 'string' ? fixGermanDigraphs(s) : s,
    )
  }
  if (Array.isArray(o.interesting_facts)) {
    o.interesting_facts = o.interesting_facts.map((f) => {
      if (f && typeof f === 'object' && typeof f.de === 'string') {
        return { ...f, de: fixGermanDigraphs(f.de) }
      }
      return f
    })
  }
  if (Array.isArray(o.tags)) {
    o.tags = o.tags.map((t) =>
      typeof t === 'string' ? fixGermanDigraphs(t) : t,
    )
  }
  return o
}

function processFile(filePath) {
  const raw = fs.readFileSync(filePath, 'utf8')
  const data = JSON.parse(raw)
  const out = data.map((item) => processQuestion(item))
  fs.writeFileSync(filePath, `${JSON.stringify(out, null, 2)}\n`, 'utf8')
}

const files = fs
  .readdirSync(dataDir)
  .filter((f) => f.endsWith('.json'))
  .sort()

for (const f of files) {
  processFile(path.join(dataDir, f))
  console.log('OK', f)
}
console.log('Done:', files.length)
