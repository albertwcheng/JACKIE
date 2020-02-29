# JACKIE

## Installation

With root privilege:

```
./configure
make
make install
```

Install to specific path:

```
./configure --prefix=/path/to/install/
make
make install
```

Add JACKIE to path. In your ~/.bashrc file, add a line:
```
export PATH=/path/to/install/:${PATH}
```
## Example run
Download genome fasta files and produce a merged files for "non-random" chromosomes
```
genome=<fill in your genome> #e.g., hg38
genomesRoot=<fill in your genomes data root path> 
pathToGenome=$genomesRoot/$genome
genomeFasta=$pathToGenome/$genome.nr.fa

cd $pathToGenome
wget --timestamping "ftp://hgdownload.cse.ucsc.edu/goldenPath/$genome/chromosomes/*"
gunzip *.gz
mkdir random
mv *random*.fa random/
mv chrUn*.fa random/
mkdir nr
mv *.fa nr
cat nr/*.fa > $genome.nr.fa

```

Run first step of JACKIE, assuming your cluster uses `qsub`:

```
genome=<fill in your genome> #e.g., hg38
genomesRoot=<fill in your genomes data root path> 
pathToGenome=$genomesRoot/$genome
genomeFasta=$pathToGenome/$genome.nr.fa

jackieDB=$pathToGenome/jackieDB/
mkdir $jackieDB

#generate binary represetation of sgRNA binding locations

for N in A C G T; do
echo "date; JACKIE -b2 $genomeFasta $pamFold .bin 6 $pamFold/$N.ref.txt $N n; date" | qsub -l walltime=48:00:00
done

```

<!--








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
minBS=5
maxBS=8
minDist=5000
maxDist=10000
awk -v FS="\t" -v OFS="\t" -v minBS=$minBS -v maxBS=$maxBS -v minDist=$minDist -v maxDist=$maxDist '($3-$2>=minDist && $3-$2<=maxDist && $5>=minBS && $5<=maxBS)' $pamFold/${genome}PAM.sameChr.tx.sorted.legal.bed > $pamFold/${genome}PAM.sameChr.tx.sorted.legal.Dist${minDist}_${maxDist}.BS${minBS}_${maxBS}.bed


#select unique sgRNA sites
awk -v FS="\t" -v OFS="\t" '($5==1)' $pamFold/${genome}PAM.BED > $pamFold/${genome}PAM.1copy.BED

#select sgRNA sites within region of interest


#run CasOffFinder (requires offline version of Cas-OFFinder at http://www.rgenome.net/cas-offinder/portable)
#export PATH=/usr/bin/:${PATH}
#export PATH=~/Dropbox/unixEnv/scripts:${PATH}
runCasOFFinderOnSequences.py <file> 4,/,2 3 ~/Dropbox/unixEnv/genomes/hg38/ casOffinder_outputDir > ???

#runCasOFFinderOnSequences.py newSelectionLoop.overlap.hg38PAM.sameChr.tx.sorted.legal.1copy.GC40to60.no5T.noLowercase.2.bed 17 3 ~/Dropbox/unixEnv/genomes/hg38/ newSelectionLoop.overlap.hg38PAM_off > newSelectionLoop.overlap.hg38PAM.sameChr.tx.sorted.legal.1copy.GC40to60.no5T.noLowercase.2.casOffinder.txt
```
-->
