import json,sys,glob
sys.stdout.reconfigure(encoding='utf-8')
fn,a,n=sys.argv[1],int(sys.argv[2]),int(sys.argv[3])
done=set()
for p in glob.glob(f'tools/len_patches/{fn}*.json'): done|={u['id'] for u in json.load(open(p,encoding='utf-8'))}
qs=json.load(open(f'lib/data/Fragen/Detailed/{fn}_all.json',encoding='utf-8'))
todo=[q for q in qs if q['id'] not in done and len(q['correct_answer_de'])>=50 and len(q['correct_answer_de'])>1.25*sum(len(w) for w in q['wrong_answers_de'])/3]
print(len(todo),'todo')
for q in todo[a:a+n]:
    w=q['wrong_answers_de']
    print(f"{q['id']}|{len(q['correct_answer_de'])}/{round(sum(map(len,w))/3)}|C: {q['correct_answer_de']}\n   W: {' || '.join(w)}")
