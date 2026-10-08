import json,sys
sys.stdout.reconfigure(encoding='utf-8')
CR=chr(13);LF=chr(10)
ids=set(json.loads(sys.argv[1]))
f='lib/data/Fragen/Detailed/detailed_501_550_greece_b2.json'
raw=open(f,encoding='utf-8',newline='').read();d=json.loads(raw)
out=[q for q in d if q['id'] not in ids]
s=json.dumps(out,ensure_ascii=False,indent=2)
if CR+LF in raw: s=s.replace(LF,CR+LF)
open(f,'w',encoding='utf-8',newline='').write(s+raw[len(raw.rstrip()):])
print(len(d),'->',len(out))
old=json.load(open('tools/ant_removed_ids.json'));open('tools/ant_removed_ids.json','w').write(json.dumps(sorted(set(old)|ids)))
