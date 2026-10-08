import json,glob,sys,collections,re
sys.stdout.reconfigure(encoding='utf-8')
ids=set()
for p in glob.glob('tools/medieval_patches/*.json'): ids|={u['id'] for u in json.load(open(p,encoding='utf-8'))}
qs=[]
for f in sorted(glob.glob('lib/data/Fragen/Detailed/medieval_*.json')): qs+=json.load(open(f,encoding='utf-8'))
qs=[q for q in qs if q['id'] in ids]
def norm(s): return re.sub(r'\W+',' ',s.lower()).strip()
seen=collections.defaultdict(list)
for q in qs:
    for k,t in [('E',q['explanation_de'])]+[('F',f['de']) for f in q['interesting_facts']]:
        seen[norm(t)].append(q['id'])
d=[(k[:80],v) for k,v in seen.items() if len(v)>1]
print('done',len(qs),'dup texts',len(d)); [print(' ',x) for x in d[:10]]
# similar facts: shared 6-gram
g=collections.defaultdict(set)
for q in qs:
    for t in [q['explanation_de']]+[f['de'] for f in q['interesting_facts']]:
        w=norm(t).split()
        for i in range(len(w)-5): g[' '.join(w[i:i+6])].add((q['id'],t[:0]))
sh=[(k,len({a for a,_ in v})) for k,v in g.items() if len({a for a,_ in v})>1]
print('shared 6-grams across questions:',len(sh)); [print(' ',k,n) for k,n in sorted(sh,key=lambda x:-x[1])[:15]]
d=collections.Counter(w for q in qs for w in q['wrong_answers_de'])
print('distractor reuse:',sum(v>1 for v in d.values()),'of',len(d)); print(d.most_common(8))
long=[(q['id']) for q in qs for t in [q['explanation_de'],q['explanation_ru']]+[x for f in q['interesting_facts'] for x in (f['de'],f['ru'])] if len(t.split())>30]
print('>30 words texts:',len(long))
