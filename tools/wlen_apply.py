import json,glob,sys
sys.stdout.reconfigure(encoding='utf-8')
CR=chr(13);LF=chr(10)
P={}
for p in sorted(glob.glob('tools/wlen_patches/*.json')):
    for u in json.load(open(p,encoding='utf-8')): P.setdefault(u['id'],{'id':u['id'],'w':{}})['w'].update(u['w'])
for f in glob.glob('lib/data/Fragen/Detailed/neuzeit19_*.json')+glob.glob('lib/data/Fragen/Detailed/zwanzigstes_*.json'):
    raw=open(f,encoding='utf-8',newline='').read();d=json.loads(raw)
    for q in d:
        u=P.get(q['id'])
        if not u: continue
        for i,(de,ru) in u['w'].items():
            q['wrong_answers_de'][int(i)]=de;q['wrong_answers_ru'][int(i)]=ru
    if json.loads(raw)==d: continue
    out=json.dumps(d,ensure_ascii=False,indent=2)
    if CR+LF in raw: out=out.replace(LF,CR+LF)
    open(f,'w',encoding='utf-8',newline='').write(out+raw[len(raw.rstrip()):])
    print('updated',f)
