#/bin/bash

if [ $# -lt 2 ]; then
	echo $0 pamFoldDir prefix
	exit 1
fi

pamFoldDir=$1
prefix=$2


echo pamFoldDor=$pamFoldDir prefix=$prefix


for i in $pamFoldDir/${prefix}*.bin; do
	JACKIE -f3 $pamFoldDir/A.ref.txt $i ${i/.bin/}.bed 1 0
done