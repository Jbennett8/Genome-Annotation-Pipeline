#!/bin/bash

module load hisat2/2.2.1

# Input
sraName="$1" # etc SRR123775
sraDir="$PWD/$2"
outDir="$3"

readType="scythe" # Change if you want just trimmed, etc
r1=$sraDir/${readType}_${sraName}_1.fastq
r2=$sraDir/${readType}_${sraName}_2.fastq

# Parameters
cores=8
prefix="$PWD/index/hisat/hisat"


# Create sam
cd $outDir
script="hisat2 -p $cores -q -x $prefix -1 $r1 -2 $r2 > ${sraName}.sam"
eval $script

# Immediately convert to bam and delete sam
script="samtools view -b -@ $cores ${sraName}.sam | samtools sort -o sorted_${sraName}.bam -@ $cores"
eval "$script" && rm ${sraName}.sam


