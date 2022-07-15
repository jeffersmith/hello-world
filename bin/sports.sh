#!/usr/bin/bash
#PBS -l nodes=1:ppn=8
#PBS -l mem=12gb
#PBS -l walltime=10:00:00
#PBS -d ./
#PBS -j oe

start=`date +%s`

CPU=$PBS_NP
if [ ! $CPU ]; then
   CPU=2
fi

N=$PBS_ARRAYID
if [ ! $N ]; then
    N=`wc -l file.list`
fi

#----------------
#for i in $(seq 1 $1);do
ctg=`less file.list | head -n $N | cut -f1 | tail -n 1`
treat=`less file.list | head -n $N | cut -f2 | tail -n 1`
prefix=${ctg}
gff='../../ath.gff3'
genome='/public1/home/shijf/software/sports1.1-master/lib/Arabidopsis_thaliana/Ensembl/TAIR10/Sequence/BowtieIndex/genome'
mirbase='/public1/home/shijf/software/sports1.1-master/lib/Arabidopsis_thaliana/miRBase_21/miRBase_21-ath'
rrnabase='/public1/home/shijf/software/sports1.1-master/lib/Arabidopsis_thaliana/rRNAdb/Arabidopsis_rRNA'
trnabse='/public1/home/shijf/software/sports1.1-master/lib/Arabidopsis_thaliana/GtRNAdb/araTha1-tRNAs'
rfam='/public1/home/shijf/software/sports1.1-master/lib/Arabidopsis_thaliana/Rfam_12.3/Rfam-12.3-arabidopsis'
nocrna='/public1/home/shijf/software/sports1.1-master/lib/Arabidopsis_thaliana/Ensembl/Arabidopsis_thaliana.TAIR10.ncrna'

program1="fa2total.py"
program2="length_AUCG.py"
program3="get_fa.py"

echo "CPU= $CPU"
echo "FILE= $ctg"
echo "FILE_PREFIX= $prefix"

if [ ! -e fastqc ]; then
   mkdir fastqc
fi
   echo "fastqc"
   gzip -d fastq/${ctg}.fastq.gz
   fastqc fastq/${ctg}.fastq -o fastqc/

   echo "adaptor trimming"
   python adapt_find.py ILLUMINA --files fastq/${ctg}.fastq --output_path ./
#   fastqc good-mapping/${ctg}_trimmed.fastq -o fastqc/trimmed/
   fastqc good-mapping/${ctg}_trimmed.fastq -o fastqc/trimmed/ 
if [ ! -e out ]; then
   mkdir out
fi
if [ ! -e result ]; then
   mkdir result
fi
   echo "mapping genome"

if [ ! -f out/${ctg}/1_${ctg}_trimmed/${ctg}_trimmed_result/${ctg}_trimmed_summary.txt ];then
   sports.pl -i good-mapping/${ctg}_trimmed.fastq -p $CPU -g $genome -m $mirbase -r $rrnabase -t $trnabse -e $nocrna -f $rfam -o out/${ctg} -k -l 15 -L 50 -z
fi

   echo "miRNA count"

   bowtie -q -v 1 -S -m 1 -t -a --best --strata -p $CPU $genome good-mapping/${ctg}_trimmed.fastq ${ctg}.sam > ${i}_log.txt 2>&1
   bioawk -c sam -H '!and($flag,4)' ${ctg}.sam > ${ctg}-new.sam
   samtools view -bS -q 20 ${ctg}.sam > ${ctg}.bam
   
   samtools sort -@ 8 ${ctg}.bam -o ${ctg}_sort.bam
   samtools index ${ctg}_sort.bam
   featureCounts -t miRNA -g Name -s 1 -a $gff -o result/${prefix}-new.txt ${prefix}_sort.bam
   rm ${prefix}.sam ${prefix}.bam ${prefix}-new.sam
   echo ${ctg} ${total_reads}
   echo "data process"
   bamToFastq -i ${ctg}_sort.bam -fq ${ctg}.fq
   seqkit fq2fa ${ctg}.fq > ${ctg}_mapping.fa
   python $program2 ${ctg}_mapping.fa result/${ctg}_aucg.txt $treat $ctg
   rm ${ctg}.fq ${ctg}_sort.bam ${ctg}_mapping.fa
   
#done
#----------------
end=`date +%s`
runtime=$((end-start))
h=$(($runtime/3600))
hh=$(($runtime%3600))
m=$(($hh/60))
s=$(($hh%60))

echo "Start= $start"
echo "End= $end"
echo "Run time= $h:$m:$s"
echo "Done!"
