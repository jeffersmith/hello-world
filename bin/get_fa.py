#!usr/bin/python
import sys

def usage():
    print('Usage: python3 script.py [fasta_file] [path_file] [outfile_name]')

def list_open(file):
    with open(file,'r') as f:
        dic=[]
        for line in f.readlines():
            line=line.strip('\n')
            dic.append(line)
    return dic


def fa_open(file):
    dict = {}
    with open(file, 'r') as fastaf:
        for line in fastaf:
            if line.startswith('>'):
                name = line.strip()[1:]
                dict[name] = ''
            else:
                dict[name] += line.replace('\n','')
    return dict

def diminish(dict1,list2): #dict1: a fasta dict,key is str after >;value is the line;
    re_num={}
    for num in range(len(list2)): 
        fa2=fa_open(list2[num])
        deal_num=0
        for key in fa2.keys():
            if key in dict1.keys():
                deal_num += 1
                del dict1[key]
            else:
                print('an unexpect error')
        re_num[list2[num]]=deal_num
    return dict1,re_num

##define a funtion to continuous diminish a dict items which exist in another or a series of dictby their key


fa1=fa_open(sys.argv[1])
fa2=list_open(sys.argv[2])

result,num_result=diminish(fa1,fa2)
#print(num_result)

with open(sys.argv[3],'w') as f:
    for key in result.keys():
        f.write('>' + key+ '\n')
        f.write(result[key] + '\n')

for i in num_result:
    print("%s: %s reads have been deleted"%(i.split('/')[-1],num_result[i]))

