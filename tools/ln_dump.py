import json,sys,glob
sys.stdout.reconfigure(encoding='utf-8')
pat={'medieval':'medieval_[0-9]*','em':'early_modern_[0-9]*'}[sys.argv[1]]
a,n=int(sys.argv[2]),int(sys.argv[3])
done=set()
for p in glob.glob(f'tools/ln_patches/{sys.argv[1]}_*.json'): done|={u['id'] for u in json.load(open(p,encoding='utf-8'))}
qs=[]
for f in sorted(glob.glob(f'lib/data/Fragen/Detailed/{pat}.json')): qs+=json.load(open(f,encoding='utf-8'))
out=[q for q in qs if q['id'] not in done and len(q['correct_answer_de'])>=50 and len(q['correct_answer_de'])>1.25*sum(map(len,q['wrong_answers_de']))/3]
print(len(out),'todo')
for q in out[a:a+n]:
    w=q['wrong_answers_de'];r='R' if q['correct_answer_ru']!=q['correct_answer_de'] else '-'
    print(f"{q['id']}|{len(q['correct_answer_de'])}/{round(sum(map(len,w))/3)}|{r}|C: {q['correct_answer_de']}\n   W: {' || '.join(w)}")
