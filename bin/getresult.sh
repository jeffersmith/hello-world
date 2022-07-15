#!usr/bin/bash

   echo -ne "sample\ttotal reads\tclean reads\tmatched to genome\tclean reads matched to genome(without rRNA & tRNA)\t21-24nt sRNA\tmiRNA\trRNA\ttRNA\tensembl\trfam\tunannotated\tothers" >> result/result_counts.txt
   echo >> result/result_counts.txt

for i in `less file.list |cut -f1`;do
echo ${i}
total_reads=`expr $(cat fastq/${i}*.fastq |wc -l) / 4`
clean_reads=`grep -w - out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt |grep Clean_Reads |cut -f3`
match_reads=`grep -w - out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt |grep -w Match_Genome |cut -f3`
mirna=`grep -w - out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt |grep miRBase-miRNA_Match_Genome |cut -f3`
rrna_m=`less out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt | grep -w - |sed -n '/^rRNAdb-/p' |sed -n '/Match_Genome/p' | awk '{sum+=$3} END {print sum}'`
trna_m=`less out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt | grep -w - |sed -n '/^GtRNAdb-/p' |sed -n '/Match_Genome/p' | awk '{sum+=$3} END {print sum}'`
rrna=`less out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt | grep -w - |sed -n '/^rRNAdb-/p' | awk '{sum+=$3} END {print sum}'`
trna=`less out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt | grep -w - |sed -n '/^GtRNAdb-/p' | awk '{sum+=$3} END {print sum}'`
umg=`grep -w - out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt |grep Unannotated_Match_Genome |cut -f3`
uug=`grep -w - out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt |grep Unannotated_Unmatch_Genome |cut -f3`
ensembl=`less out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt | grep -w - |sed -n '/^ensembl-/p' |sed '/[tr]RNA/d'| awk '{sum+=$3} END {print sum}'`
rfam=`less out/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt | grep -w - |sed -n '/^Rfam-/p' |sed '/[tr]RNA/d'| awk '{sum+=$3} END {print sum}'`
match_nort=$((match_reads-rrna_m-trna_m));
ls out/${i}/1_${i}_trimmed/${i}_trimmed_fa/${i}_trimmed_match_[rt]RNA*_match_genome.fa > ${i}_rtrna.txt
python ~/Shijianfei/sl_sRNA/get_fa.py out/${i}/1_${i}_trimmed/${i}_trimmed_fa/${i}_trimmed_match_genome.fa ${i}_rtrna.txt ${i}_srna.fa
python /public1/home/shijf/data/AGO/fa2total.py ${i}_srna.fa ${i}_srna_all.fa
srna=`seqkit seq -m 21 -M 24 -g ${i}_srna_all.fa |seqkit stats |tail -1 | tr -s ' ' '\t' |cut -f4`
unanno=$(($umg+$uug));
rm ${i}_rtrna.txt ${i}_srna.fa ${i}_srna_all.fa

echo "total ${total} reads"

echo -ne ${i}"\t"${total_reads}"\t"${clean_reads}"\t"${match_reads}"\t"${match_nort}"\t"${srna}"\t"${mirna}"\t"${rrna}"\t"${trna}"\t"${ensembl}"\t"${rfam}"\t"${unanno} >> result/result_counts.txt
echo >> result/result_counts.txt

echo "done"
done
#clean_reads=`grep Clean_Reads out_0mis/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt |cut -f3`
#match_reads=`grep -w Match_genome out_0mis/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt |cut -f3`
#mirna=`grep miRBase-miRNA_Match_Genome i_genome out_0mis/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt |cut -f3`
#rrna_m=`grep "rRNAdb-rRNA_Match_Genome" i_genome out_0mis/${i}/1_${i}_trimmed/${i}_trimmed_result/${i}_trimmed_summary.txt |cut -f3`

