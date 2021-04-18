#!/bin/bash

module load gmap/2019-06-10

#-D /path/to/where/to/save/make/gmap/index/dir -d name_of_gmap_index_dir genome.fa

genome="$PWD/$1"
outDir="index"

cd $outDir
script="gmap_build -d gmap -D $PWD $genome"
eval "$script"

