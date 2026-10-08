import json,glob,sys,random,re,os
sys.stdout.reconfigure(encoding='utf-8')
files=sorted(glob.glob('lib/data/Fragen/Detailed/medieval_*.json'))
raw={f:open(f,encoding='utf-8',newline='').read() for f in files}
data={f:json.loads(raw[f]) for f in files}
idx={q['id']:q for d in data.values() for q in d}
def wc(s): return len(s.split())
def years(q):
    m=re.fullmatch(r'(\d{3,4}) n\. Chr\.',q['correct_answer_de'])
    if not m: return None
    Y=int(m.group(1)); r=random.Random(Y*7919+q['id']); out=set()
    scale=[r.randint(6,30),r.randint(35,90),r.randint(100,220)]
    for s in scale:
        c=Y+ s*r.choice([-1,1])
        if c<300 or c>1500 or c==Y or c in out: c=Y+s*(1 if c<Y else -1)
        if c<300 or c>1500: c=Y+(s%97)+11
        out.add(c)
    return sorted(out)
bad=0
for p in sorted(glob.glob('tools/medieval_patches/*.json')):
    for u in json.load(open(p,encoding='utf-8')):
        q=idx[u['id']]
        for k,t,r,rt in (('qd','question_de','qr','question_ru'),('cd','correct_answer_de','cr','correct_answer_ru'),('ed','explanation_de','er','explanation_ru')):
            if k in u:
                q[t]=u[k]
                if r in u: q[rt]=u[r]
                elif k=='ed': q[rt]=''
                elif k=='cd': q[rt]=u[k]
        if 'wd' in u: q['wrong_answers_de']=u['wd']; q['wrong_answers_ru']=u.get('wr') or list(u['wd'])
        elif q['type']=='date':
            ys=years(q)
            if ys: q['wrong_answers_de']=[f'{y} n. Chr.' for y in ys]; q['wrong_answers_ru']=[f'{y} г.' for y in ys]
        if 'fd' in u:
            fr=u.get('fr',['','',''])
            q['interesting_facts']=[{'de':a,'ru':b} for a,b in zip(u['fd'],fr)]
        for t in [q['explanation_de'],q['explanation_ru']]+[x for f in q['interesting_facts'] for x in (f['de'],f['ru'])]:
            if wc(t)>35: print('LONG',q['id'],wc(t))
for f,d in data.items():
    if json.loads(raw[f])==d: continue
    out=json.dumps(d,ensure_ascii=False,indent=2).replace('\n','\r\n')
    tail=raw[f][len(raw[f].rstrip()):]
    with open(f,'w',encoding='utf-8',newline='') as h: h.write(out+tail)
