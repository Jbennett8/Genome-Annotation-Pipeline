#!/bin/bash
#SBATCH --job-name=default_run
#SBATCH -o log/repeatMasker/%j.out
#SBATCH -e log/repeatMasker/%j.err
#SBATCH --ntasks=1 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=50G
#SBATCH --array=1-100%20

module load perl/5.28.1
export PATH=/labs/Wegrzyn/annotationtool/software/RepeatMasker/4.0.6:$PATH

# Inputs
speciesName="$1"
maskLib="$2"
inDir="$3" # path to pieces dir
outDir=$inDir/masked

seq="$inDir/${speciesName}.fasta${SLURM_ARRAY_TASK_ID}"
out="$outDir/${speciesName}_sm.fasta${SLURM_ARRAY_TASK_ID}"

echo "seq=$seq out=$out"

if [ -s $seq ]
then
  echo "Seq $s is non-empty, running repeatmasker!"
  RepeatMasker $seq -lib $maskLib -pa 12 -gff -a -noisy -low -xsmall | tee $out
fi
