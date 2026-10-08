import json,glob,sys
sys.stdout.reconfigure(encoding='utf-8')
CR=chr(13); LF=chr(10)
M={'qd':'question_de','qr':'question_ru','cd':'correct_answer_de','cr':'correct_answer_ru','ed':'explanation_de','er':'explanation_ru','wd':'wrong_answers_de','wr':'wrong_answers_ru'}
patches={}
for p in sorted(glob.glob('tools/nz_patches/*.json'))+sorted(glob.glob('tools/len_patches/*.json')):
    for u in json.load(open(p,encoding="utf-8")): patches.setdefault(u["id"],{}).update(u)
files=[f for f in glob.glob('lib/data/Fragen/Detailed/neuzeit19_*.json')+glob.glob('lib/data/Fragen/Detailed/zwanzigstes_*.json')]
wc=lambda s:len(s.split())
for f in files:
    raw=open(f,encoding='utf-8',newline='').read()
    d=json.loads(raw)
    for q in d:
        u=patches.get(q['id'])
        if not u: continue
        for k,t in M.items():
            if k in u: q[t]=u[k]
        if 'fd' in u: q['interesting_facts']=[{'de':a,'ru':b} for a,b in zip(u['fd'],u['fr'])]
    if json.loads(raw)==d: continue
    out=json.dumps(d,ensure_ascii=False,indent=2)
    if CR+LF in raw: out=out.replace(LF,CR+LF)
    tail=raw[len(raw.rstrip()):]
    open(f,'w',encoding='utf-8',newline='').write(out+tail)
    print('updated',f)
