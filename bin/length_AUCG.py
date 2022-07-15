import sys
from fnmatch import fnmatch
file_name=sys.argv[1]
read_line = []
line_num = 0
A=[]
T=[]
C=[]
G=[]
dic1={}
dic2={}
dic3={}
dic4={}
outfile_name=sys.argv[2]
treat=sys.argv[3]
sample=sys.argv[4]

result=["length\tA\tU\tC\tG\ttreat\tsample"]
a=[15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50]
with open(file_name, 'r') as file:
    for line in file:
        line = line.rstrip()
        line_num += 1
        if line_num % 2 == 0 and len(line) >=16 and len(line)<=50:
            read_line.append(line)
    for i in read_line:
        if i.startswith('A'):
            A.append(len(i))
        elif i.startswith('T'):
            T.append(len(i))
        elif i.startswith('C'):
            C.append(len(i))
        elif i.startswith('G'):
            G.append(len(i))
    for j in a:
        dic1[j]=A.count(j)
        dic2[j]=T.count(j)
        dic3[j]=C.count(j)
        dic4[j]=G.count(j)
    for key in dic1:
        result.append('%s\t%s\t%s\t%s\t%s\t%s\t%s' %(key,dic1[key],dic2[key],dic3[key],dic4[key],treat,sample))
outfile = open(outfile_name, 'w')
outfile.write('\n'.join(result))
outfile.close()
