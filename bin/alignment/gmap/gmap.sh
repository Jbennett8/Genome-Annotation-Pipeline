#!/bin/bash

module load gmap/2019-06-10

#-D /path/to/where/to/save/make/gmap/index/dir -d name_of_gmap_index_dir genome.fa

# Inputs
genome="$PWD/$1"
centroidsFiltered="$PWD/$2"
outDir="$3" # Where you want the aligned gff3 to be
genomeSize="$4" # large = >4billion bp

indexName="gmap"
indexDir="index"

# Parameters
cpus="8"
minCov="0.95"
minId="0.95"

cd $outDir
mkdir -p index

# Build gmap index against a genome, stored in $outDir/index
script="gmap_build -D index -d $indexName $genome"
eval "$script"

# Run gmap or gmapl aligner
if [ $genomeSize = "small" ];then
  script="gmap -a 1 --cross-species -D $indexDir -d $indexName -f gff3_gene $centroidsFiltered --fulllength --nthreads=$cpus --min-trimmed-coverage=$minCov --min-identity=$minId -n1 > gmap.gff3"
  eval $script
elif [ $genomeSize = "large" ];then
  script="gmapl -a 1 --cross-species -D $indexDir -d $indexName -f gff3_gene $centroidsFiltered --fulllength --nthreads=$cpus --min-trimmed-coverage=$minCov --min-identity=$minId -n1 > gmap.gff3"
  eval $script
else
  echo "Unknown genomeSize argument, should be 'large' or 'small'"
fi
