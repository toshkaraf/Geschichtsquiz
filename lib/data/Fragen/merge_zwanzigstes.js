const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, 'Detailed');

const files = [
  'zwanzigstes_9001_9025.json',
  'zwanzigstes_9026_9050.json',
  'zwanzigstes_9051_9075.json',
  'zwanzigstes_9076_9100.json',
  'zwanzigstes_9101_9125.json',
  'zwanzigstes_9126_9150.json',
  'zwanzigstes_9151_9175.json',
  'zwanzigstes_9176_9200.json',
  'zwanzigstes_9201_9225.json',
  'zwanzigstes_9226_9250.json',
  'zwanzigstes_9251_9275.json',
  'zwanzigstes_9276_9300.json',
];

const merged = files.flatMap(f => {
  const raw = fs.readFileSync(path.join(dir, f), 'utf8').replace(/,(\s*[}\]])/g, '$1');
  return JSON.parse(raw);
});

fs.writeFileSync(path.join(dir, 'zwanzigstes_all.json'), JSON.stringify(merged, null, 2), 'utf8');
console.log(`Merged ${merged.length} questions into zwanzigstes_all.json`);
