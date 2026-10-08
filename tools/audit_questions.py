import json,glob,re,collections,sys,os
sys.stdout.reconfigure(encoding='utf-8')
files=sorted(glob.glob('lib/data/Fragen/Detailed/*.json'))
skip=('neuzeit19_all','zwanzigstes_all')
qs=[]
for f in files:
    b=os.path.basename(f)[:-5]
    if b in skip: continue
    for q in json.load(open(f,encoding='utf-8')):
        q['_f']=b; qs.append(q)
def grp(q):
    b=q['_f']
    for k in('medieval','early_modern','neuzeit19','zwanzigstes'):
        if b.startswith(k): return k
    return 'ancient'
wc=lambda s:len(s.split())
def sents(s): return [x.strip() for x in re.split(r'(?<=[.!?])\s+',s) if len(x.strip())>25]
R=collections.defaultdict(lambda:collections.Counter())
print('total',len(qs)); ids=collections.Counter(q['id'] for q in qs)
print('dup ids',sum(1 for v in ids.values() if v>1))
for lang in('de','ru'):
    print('\n=====',lang)
    # texts
    texts=[]  # (kind,q,text)
    for q in qs:
        e=q.get('explanation_'+lang)
        if e: texts.append(('expl',q,e))
        for fa in q.get('interesting_facts',[]) or []:
            if fa.get(lang): texts.append(('fact',q,fa[lang]))
    sc=collections.Counter(); sg=collections.defaultdict(set)
    for k,q,t in texts:
        for s in sents(t):
            n=re.sub(r'\d+','#',s.lower()); sc[n]+=1; sg[n].add(grp(q))
    for kind in('expl','fact'):
        T=[(q,t) for k,q,t in texts if k==kind]
        print(f'-- {kind}: n={len(T)}')
        for g in ['ancient','medieval','early_modern','neuzeit19','zwanzigstes']:
            L=[wc(t) for q,t in T if grp(q)==g]
            if not L: continue
            print(f'  {g:13} n={len(L):5} avg={sum(L)/len(L):5.1f} >25={sum(x>25 for x in L):5} >35={sum(x>35 for x in L):5} max={max(L)}')
        ex=collections.Counter(t for q,t in T); print('  exact-duplicate texts:',sum(v for v in ex.values() if v>1),'in',sum(v>1 for v in ex.values()),'groups')
    # template: sentences repeated >=3
    rep=[(n,c) for n,c in sc.items() if c>=3]
    print('repeated sentences (>=3x):',len(rep),'covering',sum(c for n,c in rep),'occurrences')
    for n,c in sorted(rep,key=lambda x:-x[1])[:12]: print('   ',c,'x',sorted(sg[n]),n[:140])
    # template by first-5-words / frame
    pre=collections.Counter(' '.join(t.split()[:4]) for k,q,t in texts if k=='fact')
    print('top fact openings:',pre.most_common(6))
    # distractors
    d=collections.Counter()
    for q in qs:
        for w in q.get('wrong_answers_'+lang,[]): d[w.strip().lower()]+=1
    tot=sum(d.values()); print(f'distractors: total={tot} unique={len(d)}; used>=5x: {sum(1 for v in d.values() if v>=5)} items/{sum(v for v in d.values() if v>=5)} uses; >=10x: {sum(1 for v in d.values() if v>=10)}')
    print('  top:',d.most_common(15))
    for g in ['ancient','medieval','early_modern','neuzeit19','zwanzigstes']:
        dd=collections.Counter(w.strip().lower() for q in qs if grp(q)==g for w in q.get('wrong_answers_'+lang,[]))
        t=sum(dd.values()); print(f'  {g:13} total={t} unique={len(dd)} reuse-rate={1-len(dd)/max(t,1):.0%}')
# structure
miss=collections.Counter()
for q in qs:
    if len(q.get('interesting_facts') or [])!=3: miss['facts!=3']+=1
    if len(q.get('wrong_answers_de',[]))!=3: miss['wrong_de!=3']+=1
    if not q.get('explanation_de'): miss['no expl_de']+=1
    if q['correct_answer_de'].strip().lower() in [w.lower() for w in q.get('wrong_answers_de',[])]: miss['correct in wrong']+=1
print('\nstructure issues',dict(miss))
