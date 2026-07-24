const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, 'Detailed');

const files = [
  'neuzeit19_8001_8025.json',
  'neuzeit19_8026_8050.json',
  'neuzeit19_8051_8075.json',
  'neuzeit19_8076_8100.json',
  'neuzeit19_8101_8125.json',
  'neuzeit19_8126_8150.json',
  'neuzeit19_8151_8175.json',
  'neuzeit19_8176_8200.json',
  'neuzeit19_8201_8225.json',
  'neuzeit19_8226_8250.json',
  'neuzeit19_8251_8275.json',
  'neuzeit19_8276_8300.json',
];

const merged = files.flatMap(f => {
  const raw = fs.readFileSync(path.join(dir, f), 'utf8').replace(/,(\s*[}\]])/g, '$1');
  return JSON.parse(raw);
});

fs.writeFileSync(path.join(dir, 'neuzeit19_all.json'), JSON.stringify(merged, null, 2), 'utf8');
console.log(`Merged ${merged.length} questions into neuzeit19_all.json`);
