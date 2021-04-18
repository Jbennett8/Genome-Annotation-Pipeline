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
fasta="$PWD/$1"
inDir="$PWD/$2" # Directory containing trimmed sickle output
outDir="$3"
indexName="hisat"

# Parameters
cores="16"

# Build hisat index against a fasta
mkdir -p $outdir/index
cd $outDir/index
script="hisat2-build -f $fasta $indexName"
eval "$script"
cd ..


# Gather accessions from input dir
# Echo's everything in the input dir and looks for things that look like trimmed_SRR891273.fasta, and takes the SRR891273 part to use later
uniqueAccessions=$(echo $inDir/* | tr " " "\n" | sed -E 's/trimmed_([A-Z]{3}[0-9]+)(_[0-9])?.fastq/\1/;t;d' | sort -u)
if [[ -z $uniqueAccessions ]]; then
  echo "ERR: Couldnt find any trimmed SRA accessions in the input dir $inDir, double check that you provided the directory that contains sickle output"
  exit 1
fi

# For each ncbi accession, generate sam alignment
for i in $uniqueAccessions; do
  echo $i
  f1=$inDir/trimmed_${i}_1.fastq
  f2=$inDir/trimmed_${i}_2.fastq
  if [[ -z $f1 || -z $f2 ]]; then
    echo "ERR: One of the read pairs for $i is empty, exiting now"
    exit 1
  fi
  echo "Generating sam file ${i}.sam"
  hisat2 -p $cores -q -x $indexName -1 $f1 -2 $f2 > ${readName}.sam
done

# Convert each sam to bam format
for i in $uniqueAccessions; do
  samFile=$outDir/${i}.sam
  if [[ ! -s $samFile ]]; then
    echo "ERR: Expected samfile $samFile doesnt exist"
    exit 1
  fi
  outName=$(basename $samFile)
  script="samtools view -b -@ $cores $f | samtools sort -o sorted_${outName%.sam}.bam -@ $cores"
  eval "$script" && rm $samFile
done

# Merge all bams
script=$( echo "samtools merge merged.bam sorted_*.bam" )
eval $script
