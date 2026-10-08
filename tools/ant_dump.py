import json,glob,sys
sys.stdout.reconfigure(encoding='utf-8')
a,n=int(sys.argv[1]),int(sys.argv[2])
done=set()
for p in glob.glob('tools/ant_patches/*.json'): done|={u['id'] for u in json.load(open(p,encoding='utf-8'))}
seen=set();qs=[]
for f in sorted(glob.glob('lib/data/Fragen/Detailed/detailed_*.json')):
    for q in json.load(open(f,encoding='utf-8')):
        if q['id'] not in seen: seen.add(q['id']);qs.append(q)
qs.sort(key=lambda q:q['id'])
todo=[q for q in qs if q['id'] not in done]
print(len(todo),'todo')
for q in todo[a:a+n]:
    print(f"{q['id']}|{q['question_de']}|C: {q['correct_answer_de']}|W: {' / '.join(q['wrong_answers_de'])}\n  E{'' if len(q['explanation_de'].split())<=27 else ' LONG'+str(len(q['explanation_de'].split()))}: {q['explanation_de'][:200]}")
    for x in q['interesting_facts']: print('  F:',x['de'][:160])
