import json,sys,glob
sys.stdout.reconfigure(encoding='utf-8')
fn,a,n=sys.argv[1],int(sys.argv[2]),int(sys.argv[3])
done=set()
for p in glob.glob(f'tools/wlen_patches/p2_{fn}*.json'): done|={u['id'] for u in json.load(open(p,encoding='utf-8'))}
qs=json.load(open(f'lib/data/Fragen/Detailed/{fn}_all.json',encoding='utf-8'))
out=[]
for q in qs:
    if q['id'] in done: continue
    c=len(q['correct_answer_de']);w=q['wrong_answers_de']
    long=[i for i,x in enumerate(w) if len(x)>c+12 and len(x)>=62]
    if long: out.append((q,c,long))
print(len(out),'todo')
for q,c,long in out[a:a+n]:
    print(f"{q['id']}|c={c}|C: {q['correct_answer_de']}")
    for i in long: print(f"  {i}({len(q['wrong_answers_de'][i])}): {q['wrong_answers_de'][i]}")
