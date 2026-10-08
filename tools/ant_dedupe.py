import json,sys
sys.stdout.reconfigure(encoding='utf-8')
CR=chr(13);LF=chr(10)
f='lib/data/Fragen/Detailed/detailed_501_550_greece_b2.json'
raw=open(f,encoding='utf-8',newline='').read();d=json.loads(raw)
seen=set();out=[];rm=[]
for q in d:
    k=q['question_de']
    if k in seen: rm.append(q['id']);continue
    seen.add(k);out.append(q)
s=json.dumps(out,ensure_ascii=False,indent=2)
if CR+LF in raw: s=s.replace(LF,CR+LF)
open(f,'w',encoding='utf-8',newline='').write(s+raw[len(raw.rstrip()):])
print(len(d),'->',len(out),'removed',len(rm))
open('tools/ant_removed_ids.json','w').write(json.dumps(rm))
