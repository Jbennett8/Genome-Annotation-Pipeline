#!/bin/bash
#SBATCH --job-name=splitChroms
#SBATCH -o %x%j.out
#SBATCH -e %x%j.err
#SBATCH --ntasks=1 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=30G

# Splits a genome file into its chromosomes
# Usually only useful for a chromosomal level assembly

module load samtools/1.9

# inputs
genome="$PWD/$1"
outDir="$2"

# parameters
chromosomeFile="$PWD/genome/maker/chromosomes/chromosomes.txt"

if [ ! -s $chromosomeFile ];
then
  echo "ERR (splitChroms.sh): Chromosome file missing or empty $chromosomeFile"
  exit 1
fi

# Index if necessary
if [ ! -s ${genome}.fai ]; then
  echo "Indexing genome before splitting"
  samtools faidx $genome
fi

cd $outDir

while read -r line; do
  echo "Splitting Chromosome $line"
  samtools faidx $genome $line > ${line}.fasta
done < $chromosomeFile

# Sanity check that this worked
while read -r line; do
  if [ ! -s ${line}.fasta ];then
    echo "We are missing chromosome file $line after our split, check splitChroms.sh for debugging"
    exit 1
  fi
done < $chromosomeFile

echo "Completed step" > completed.txt
