#!/usr/bin/bash

##mapping reada

N=`wc -l file.list`
#qsub -q fat -t 1-$N sports.sh
#bash sports.sh $N

rm -r aux_files/ bad-mapping/ no_overepresented_sequences/ master_adapters.csv

if [ -f result/result_AUCG.txt ];then
rm result/result_AUCG.txt
fi

sed '' result/*_aucg.txt |sed '2,$ s/^length.*//g'  |sed '/^$/d' > result/result_AUCG.txt
bash getresult.sh

for i in `ls result/*-new.txt`;do sed 1d ${i} |cut -f7 |sed 's/_sort\.bam//g' > ${i}.tmp;done && ls result/*-new.txt |head -1 |xargs cat |sed 1d |cut -f1 |paste - *.tmp > result/result_diff.txt && rm *.tmp

PtR -m result/result_diff.txt -s file.list --log2 --sample_cor_matrix
Rscript plot.R

