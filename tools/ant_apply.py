import json,glob,sys
sys.stdout.reconfigure(encoding='utf-8')
CR=chr(13);LF=chr(10)
M={'qd':'question_de','cd':'correct_answer_de','cr':'correct_answer_ru','ed':'explanation_de','er':'explanation_ru','wd':'wrong_answers_de','wr':'wrong_answers_ru'}
P={}
for p in sorted(glob.glob('tools/ant_patches/*.json')):
    for u in json.load(open(p,encoding='utf-8')): P.setdefault(u['id'],{}).update(u)
for f in glob.glob('lib/data/Fragen/Detailed/detailed_*.json'):
    raw=open(f,encoding='utf-8',newline='').read();d=json.loads(raw)
    for q in d:
        u=P.get(q['id'])
        if not u: continue
        for k,t in M.items():
            if k in u: q[t]=u[k]
        if 'ed' in u and 'er' not in u: q['explanation_ru']=''
        if 'fd' in u:
            fr=u.get('fr') or ['']*len(u['fd'])
            q['interesting_facts']=[{'de':a,'ru':b} for a,b in zip(u['fd'],fr)]
    if json.loads(raw)==d: continue
    out=json.dumps(d,ensure_ascii=False,indent=2)
    if CR+LF in raw: out=out.replace(LF,CR+LF)
    open(f,'w',encoding='utf-8',newline='').write(out+raw[len(raw.rstrip()):])
    print('updated',f)
