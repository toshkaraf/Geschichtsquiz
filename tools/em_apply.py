import json,glob,sys
sys.stdout.reconfigure(encoding='utf-8')
CR=chr(13); LF=chr(10)
files=sorted(glob.glob('lib/data/Fragen/Detailed/early_modern_*.json'))
raw={f:open(f,encoding='utf-8',newline='').read() for f in files}
data={f:json.loads(raw[f]) for f in files}
idx={q['id']:q for d in data.values() for q in d}
M={'qd':'question_de','qr':'question_ru','cd':'correct_answer_de','cr':'correct_answer_ru','ed':'explanation_de','er':'explanation_ru','wd':'wrong_answers_de','wr':'wrong_answers_ru'}
for p in sorted(glob.glob('tools/early_modern_patches/*.json')):
    for u in json.load(open(p,encoding='utf-8')):
        q=idx[u['id']]
        for k,t in M.items():
            if k in u: q[t]=u[k]
        if 'fd' in u: q['interesting_facts']=[{'de':a,'ru':b} for a,b in zip(u['fd'],u['fr'])]
for f,d in data.items():
    if json.loads(raw[f])==d: continue
    out=json.dumps(d,ensure_ascii=False,indent=2)
    if CR+LF in raw[f]: out=out.replace(LF,CR+LF)
    tail=raw[f][len(raw[f].rstrip()):]
    with open(f,'w',encoding='utf-8',newline='') as h: h.write(out+tail)
