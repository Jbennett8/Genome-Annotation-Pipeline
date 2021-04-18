#!/bin/bash
#SBATCH --job-name=hisat
#SBATCH -o %x%j.out
#SBATCH -e %x%j.err
#SBATCH --ntasks=1 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=150G

module load hisat2/2.2.1

## Aligns all trimmed short reads in a directory to an input fasta
## Converts to Bam format, removing huge Sam files as quickly as possible

# Inputs, paths are relative
genome="$PWD/$1"
indexName="hisat"

# Build hisat index against a fasta
cd index/hisat
script="hisat2-build -f $fasta $indexName"
eval "$script"
