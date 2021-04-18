module load quast/5.0.2
module load python/3.6.3

# Script inputs, paths are given relative to Snakemake file
genome="$PWD/$1"

# Running directory
dir="$2"
cd $dir

script="python /isg/shared/apps/quast/5.0.2/quast.py $genome -o $PWD"

eval "$script"
