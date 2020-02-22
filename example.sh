
#remember to add JACKIE to your path in ~/.bashrc file
#
#e.g.,
#export PATH=/hpcdata/wcheng/test/bin:${PATH}
#
#

genome=<fill in your genome> #e.g., hg38
genomesRoot=<fill in your root path> #e.g.,/hpcdata/wcheng/genomes
pathToGenome=$genomesRoot/$genome
genomeFasta=$pathToGenome/$genome.nr.fa
pamFold=$pathToGenome/pamFold/

#download genome fasta files and produce a merged files for non-random chromosomes
cd $pathToGenome
wget --timestamping "ftp://hgdownload.cse.ucsc.edu/goldenPath/$genome/chromosomes/*"
gunzip *.gz
mkdir random
mv *random*.fa random/
mv chrUn*.fa random/
mkdir nr
mv *.fa nr
cat nr/*.fa > $genome.nr.fa
mkdir $pamFold


#generate binary represetation of sgRNA binding locations
for N in A C G T; do
echo "date; JACKIE -b2 $genomeFasta $pamFold .bin 6 $pamFold/$N.ref.txt $N n; date" | qsub -l walltime=48:00:00
done

#output bed file from binary files.
for prefix in AA AC AT AG CA CC CT CG TA TC TT TG GA GC GT GG; do
echo "date; outbedForPrefixJob.sh $pamFold $prefix 1 0; date" | qsub -l walltime=24:00:00 -e `pwd`/$prefix.stderr.txt -o `pwd`/$prefix.stdout.txt	
done

#concatenate all bed files into one
echo "cat $pamFold/*.bed > $pamFold/${genome}PAM.BED" | qsub -l walltime=24:00:00

#collapse sgRNA binding locations with same sequecnes into an extended bed format
echo "chainExonBedsToTranscriptBed.py $pamFold/${genome}PAM.BED 0 > $pamFold/${genome}PAM.sameChr.tx.bed" | qsub -l walltime=24:00:00

#sort extended bed file
echo "sort -k1,1 -k2,2n $pamFold/${genome}PAM.sameChr.tx.bed > $pamFold/${genome}PAM.sameChr.tx.sorted.bed" | qsub -l walltime=24:00:00

#remove entries with overlapping sgRNA sites.
echo "removeIllegalBlockEntries.py $pamFold/${genome}PAM.sameChr.tx.sorted.bed $pamFold/${genome}PAM.sameChr.tx.sorted.legal.bed $pamFold/${genome}PAM.sameChr.tx.sorted.illegal.bed" | qsub -l walltime=24:00:00


#optional:
#select clustered sgRNA with (minBS)5 to (maxBS)8 binding sites and within (minDist)5kb to (maxDist)10kb distance
awk -v FS="\t" -v OFS="\t" -v minBS=5 -v maxBS=8 -v minDist=5000 -v maxDist=10000 '($3-$2>=minDist && $3-$2<=maxDist && $5>=minBS && $5<=maxBS)' $pamFold/${genome}PAM.sameChr.tx.sorted.legal.bed > $pamFold/${genome}PAM.sameChr.tx.sorted.legal.Dist${minDist}_${maxDist}.BS${minBS}_${maxBS}.bed


