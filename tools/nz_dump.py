import json,sys,glob
sys.stdout.reconfigure(encoding='utf-8')
fn,a,n=sys.argv[1],int(sys.argv[2]),int(sys.argv[3])
wc=lambda s:len(s.split())
done=set()
for p in glob.glob(f'tools/nz_patches/{fn}*.json'): done|={u['id'] for u in json.load(open(p,encoding='utf-8'))}
qs=json.load(open(f'lib/data/Fragen/Detailed/{fn}_all.json',encoding='utf-8'))
todo=[q for q in qs if (wc(q['explanation_de'])>27 or wc(q["explanation_ru"])>27) and q['id'] not in done]
print(len(todo),'todo')
for q in todo[a:a+n]:
    print(f"{q['id']}|{q['question_de'][:90]}|C: {q['correct_answer_de'][:50]}\n  E: {q['explanation_de']}")
