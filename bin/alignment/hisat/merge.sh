#!/bin/bash

module load hisat2/2.2.1

# Input
inDir="$1"

cd $inDir

script=$( echo "samtools merge merged.bam sorted_*.bam" )
eval $script

