#!/bin/bash
#SBATCH --job-name=default
#SBATCH -o %x%j.out
#SBATCH -e %x%j.err
#SBATCH --ntasks=1 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=100G

module load busco/5.0.0

augPath=/labs/Wegrzyn/annotationtool/software/Augustus_3.4.0
export PATH=$augPath/bin:$augPath/scripts:$PATH
export AUGUSTUS_CONFIG_PATH=$augPath/config

# Script inputs, paths are given relative to Snakemake file
input="$PWD/$1"
busco_db="$2"

# Running directory
dir="$3"
cd $dir

cores="10"

# Check input filetype (genome/proteins/etc)
if [[ $input == *.fasta || $input == *.fasta-filtered ]];then
  script="busco -i $input -l $busco_db -o busco_o -m genome -c $cores -f"
  echo $script
  eval "$script"
elif [[ $input == *.aa || $input == *.pep ]];then
  script="busco -i $input -l $busco_db -o busco_o -m proteins -c $cores -f"
  echo $script
  eval "$script"
elif [[ $input == *.trans ]];then
  script="busco -i $input -l $busco_db -o busco_o -m transcriptome -c $cores -f"
  echo $script
  eval "$script"
else
  echo "Input filetype not recognized (does not end in .fasta, .aa, .pep, or .trans)"
fi
