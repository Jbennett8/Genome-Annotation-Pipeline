#!/bin/bash
#SBATCH --job-name=filterFasta
#SBATCH -o %x%j.out
#SBATCH -e %x%j.err
#SBATCH --ntasks=1 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=30G

module load biopython/1.70
module load numpy/1.6.2

# Inputs
fasta="$PWD/$1" # should end in .fasta
name=$(basename $fasta)
length="$2"
outDir="$3"
out=$outDir/${name%.fasta}_filtered.fasta

script="bin/aux/./filterLen.py --fasta $fasta --length $length --out $out"
eval "$script"

if [[ "$?" != 0 ]]; then
  echo "Current directory = $PWD"
  echo "Running $script failed"
  exit 1
fi

