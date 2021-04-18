#!/bin/bash
#SBATCH --job-name=repeatSubmit
#SBATCH -o %x%j.out
#SBATCH -e %x%j.err
#SBATCH --ntasks=1 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=50G

module load anaconda

# Inputs
fasta="$PWD/$1"
speciesName="$2"
maskLib="$3"
outDir="$4" # Usually points to genome or genome/maker

# Parameters
pieces="100"

mkdir -p log/repeatMasker
mkdir -p $outDir/pieces/masked

# Split the genome fasta into equal pieces
echo "Splitting Genome"
bin/aux/./splitFasta.py --fasta $fasta --speciesName $speciesName --pieces $pieces --pathOut $outDir/pieces
echo "Done!"
#
# -W: wait for array job to finish before exiting
sbatch -W bin/repeatMask/repeatMasker.sh $speciesName $maskLib $outDir/pieces &
wait

cat $outDir/pieces/*.masked > $outDir/${speciesName}_sm.fasta
