#!/bin/bash

module load gmap/2019-06-10

centroidsFiltered="$PWD/$1"
outDir="$2" # Where you want the aligned gff3 to be
genomeSize="$3" # large = >4billion bp

# Parameters
indexDir="$PWD/index/gmap"
indexName="gmap" # Assumed by pipeline
cpus="8"
minCov="0.95"
minId="0.95"

# Run gmap or gmapl aligner
cd $outDir
if [ $genomeSize = "small" ];then
  script="gmap -a 1 --cross-species -D $indexDir -d $indexName -f gff3_gene $centroidsFiltered --fulllength --nthreads=$cpus --min-trimmed-coverage=$minCov --min-identity=$minId -n1 > gmap.gff3"
  eval $script
elif [ $genomeSize = "large" ];then
  script="gmapl -a 1 --cross-species -D $indexDir -d $indexName -f gff3_gene $centroidsFiltered --fulllength --nthreads=$cpus --min-trimmed-coverage=$minCov --min-identity=$minId -n1 > gmap.gff3"
  eval $script
else
  echo "Unknown genomeSize argument, should be 'large' or 'small'"
fi

