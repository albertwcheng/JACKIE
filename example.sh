
#remember to add JACKIE to your path, e.g.,
#export PATH=/hpcdata/wcheng/test/bin:${PATH}
#
#

genome=hg38
pathToGenome=/hpcdata/wcheng/genomes/$genome
genomeFasta=$pathToGenome/$genome.nr.fa
pamFold=$pathToGenome/pamFold/

#download hg38
#cd $pathToGenome
#wget --timestamping 'ftp://hgdownload.cse.ucsc.edu/goldenPath/mm10/chromosomes/*'
#gunzip *.gz
#mkdir random
#mv *random*.fa random/
#mv chrUn*.fa random/
#mkdir nr
#mv *.fa nr
#cat nr/*.fa > $genome.nr.fa
#mkdir $pamFold


for N in A C G T; do
echo "date; JACKIE -b2 $genomeFasta $pamFold .bin 6 $pamFold/$N.ref.txt $N n; date" | qsub -l walltime=48:00:00
done


for prefix in AA AC AT AG CA CC CT CG TA TC TT TG GA GC GT GG; do
echo "date; outbedForPrefixJob.sh $pamFold $prefix 1 0; date" | qsub -l walltime=24:00:00 -e `pwd`/$prefix.stderr.txt -o `pwd`/$prefix.stdout.txt	
done

cat $pamFold/*.bed > $pamFold/${genome}PAM.BED

echo "chainExonBedsToTranscriptBed.py $pamFold/${genome}PAM.BED 0 > $pamFold/${genome}PAM.sameChr.tx.bed" | qsub -l walltime=24:00:00

echo "sort -k1,1 -k2,2n $pamFold/${genome}PAM.sameChr.tx.bed > $pamFold/${genome}PAM.sameChr.tx.sorted.bed" | qsub -l walltime=24:00:00

echo "removeIllegalBlockEntries.py $pamFold/${genome}PAM.sameChr.tx.sorted.bed $pamFold/${genome}PAM.sameChr.tx.sorted.legal.bed $pamFold/${genome}PAM.sameChr.tx.sorted.illegal.bed" | qsub -l walltime=24:00:00




