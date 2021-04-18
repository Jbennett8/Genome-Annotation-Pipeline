#!/bin/bash
#SBATCH --job-name=scythe
#SBATCH -o %x%j.out
#SBATCH -e %x%j.err
#SBATCH --ntasks=1 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=10G

module load scythe/0.994

adapter=/isg/shared/apps/scythe/0.994/illumina_adapters.fa

trimmedDir="$PWD/$1"
outDir="$2"

cd $outDir

uniqueAccessions=$(echo $trimmedDir/* | tr " " "\n" | sed -E 's/trimmed_([A-Z]{3}[0-9]+)(_[0-9])?.fastq/\1/;t;d' | sort -u)

for i in $uniqueAccessions; do
  i=$(basename $i)
  r1=$trimmedDir/trimmed_${i}_1.fastq
  r2=$trimmedDir/trimmed_${i}_2.fastq
  scythe -a $adapter -o scythe_${i}_1.fastq $r1
  scythe -a $adapter -o scythe_${i}_2.fastq $r2
done

