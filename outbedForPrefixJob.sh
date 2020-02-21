#/bin/bash

if [ $# -lt 2 ]; then
	echo $0 pamFoldDir prefix thrLo thrHi
	exit 1
fi

pamFoldDir=$1
prefix=$2
#thrLo=$3
#thrHi=$4

echo pamFoldDor=$pamFoldDir prefix=$prefix


for i in $pamFoldDir/${prefix}*.bin; do
	JACKIE -f3 $pamFoldDir/A.ref.txt $i ${i/.bin/}.${thrLo}-${thrHi}.bed 1 0
done