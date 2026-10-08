import json,glob,sys
CR=chr(13);LF=chr(10)
P={}
for p in sorted(glob.glob('tools/ln_patches/*.json')):
    for u in json.load(open(p,encoding='utf-8')): P[u['id']]=u
for f in glob.glob('lib/data/Fragen/Detailed/medieval_[0-9]*.json')+glob.glob('lib/data/Fragen/Detailed/early_modern_[0-9]*.json'):
    raw=open(f,encoding='utf-8',newline='').read();d=json.loads(raw)
    for q in d:
        u=P.get(q['id'])
        if not u: continue
        old=q['correct_answer_de']
        same=q['correct_answer_ru']==old
        q['correct_answer_de']=u['cd']
        q['correct_answer_ru']=u['cr'] if 'cr' in u else (u['cd'] if same else q['correct_answer_ru'])
    if json.loads(raw)==d: continue
    out=json.dumps(d,ensure_ascii=False,indent=2)
    if CR+LF in raw: out=out.replace(LF,CR+LF)
    open(f,'w',encoding='utf-8',newline='').write(out+raw[len(raw.rstrip()):])
    print('updated',f)
