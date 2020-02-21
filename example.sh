

export PATH=/hpcdata/wcheng/test/bin:${PATH}

genome=hg38
genomeFasta=/hpcdata/wcheng/genomes/$genome/$genome.nr.fa
pamFold=/hpcdata/wcheng/genomes/$genome/pamFold/

mkdir $pamFold


for N in A C G T; do
echo "JACKIE -b2 $genomeFasta $pamFold .bin 6 $pamFold/$N.ref.txt $N n" | qsub -l walltime=48:00:00
done


for prefix in AA AC AT AG CA CC CT CG TA TC TT TG GA GC GT GG; do
echo "outbedForPrefixJob.sh $pamFold $prefix 1 0" | qsub -l walltime=24:00:00 -e `pwd`/$prefix.stderr.txt -o `pwd`/$prefix.stdout.txt	
done

cat $pamFold/*.bed > $pamFold/${genome}PAM.BED

echo "chainExonBedsToTranscriptBed.py $pamFold/${genome}PAM.BED 0 > $pamFold/${genome}PAM.sameChr.tx.bed" | qsub -l walltime=24:00:00

echo "sort -k1,1 -k2,2n $pamFold/${genome}PAM.sameChr.tx.bed > $pamFold/${genome}PAM.sameChr.tx.sorted.bed" | qsub -l walltime=24:00:00

echo "removeIllegalBlockEntries.py $pamFold/${genome}PAM.sameChr.tx.sorted.bed $pamFold/${genome}PAM.sameChr.tx.sorted.legal.bed $pamFold/${genome}PAM.sameChr.tx.sorted.illegal.bed" | qsub -l walltime=24:00:00






#echo "chainExonBedsToTranscriptBed.py `pwd`/${genome}PAM.BED 0 > `pwd`/${genome}PAM.sameChr.tx.bed" | qsub -l walltime=24:00:00
#echo "sort -k1,1 -k2,2n `pwd`/${genome}PAM.sameChr.tx.bed > `pwd`/${genome}PAM.sameChr.tx.sorted.bed" | qsub -l walltime=24:00:00
#echo "removeIllegalBlockEntries.py `pwd`/${genome}PAM.sameChr.tx.sorted.bed `pwd`/${genome}PAM.sameChr.tx.sorted.legal.bed `pwd`/${genome}PAM.sameChr.tx.sorted.illegal.bed" | qsub -l walltime=24:00:00