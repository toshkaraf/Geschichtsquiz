import json,glob,sys,re
sys.stdout.reconfigure(encoding='utf-8')
qs=[]
for f in sorted(glob.glob('lib/data/Fragen/Detailed/medieval_*.json')): qs+=json.load(open(f,encoding='utf-8'))
done=set()
for p in glob.glob('tools/medieval_patches/*.json'): done|={u['id'] for u in json.load(open(p,encoding='utf-8'))}
def per(q):
    m=re.search(r'\d+',q['period']); return int(m.group()) if m else 0
rest=sorted([q for q in qs if q['id'] not in done],key=lambda q:(per(q),q['tags'][:1],q['id']))
n=int(sys.argv[1])
print(len(rest),'remaining')
for q in rest[:n]:
    print(f"{q['id']}|{q['type'][:4]}|{q['period']}|{q['question_de'][:110]}|C: {q['correct_answer_de'][:70]}")
