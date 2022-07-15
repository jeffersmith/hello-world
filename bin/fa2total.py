#!/usr/bin/python
import sys
input_file  = sys.argv[1]
with open(input_file,'r') as f:
    seq={}
    counts={}
    for line in f:
        if line.startswith('>'):
            name = line.replace('>','').split()[0]
            seq[name]=''
            counts[name]=line.replace('>','').split()[-1]
        else:
            seq[name]+=line.replace('\n','').strip()
out_file=sys.argv[2]
result_data=[]
for key in counts:
    a=int(counts[key])
    if key in seq:
        for i in range(a):
            result_data.append(">%s\n%s" %(key,''.join(seq[key])))
with open(out_file,'w')as o:
    o.writelines('\n'.join(result_data))

