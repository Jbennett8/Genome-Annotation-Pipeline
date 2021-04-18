#!/bin/bash

# Also assumes chromosomes in fasta file have headers like this '>Chr8'

genome="$PWD/$1"
outDir="$2"

if [ ! -d $outDir ]; then
  mkdir -p $outDir
fi

cd $outDir

# Attempt to convert chromosome headers into
# >Chr(number)
# Parses for header lines that contain "chromosome","chr", etc and a number
# Definitely might need to be tweaked on a per-fasta file level unfortunately
#sed -i -e 's/>\([0-9]\+\)*[cC][hH][rR]*/>Chr\1/' $genome
sed -i 's/>\([0-9]\+\).*[cC][hH][rR].*/>Chr\1/' $genome

grep ">Chr" $genome | sed 's/>//' > chromosomes.txt

if [ ! -s chromosomes.txt ]; then
  echo "ERR (getChroms.sh) $outDir/chromosomes.txt is empty"
  exit 2
fi
