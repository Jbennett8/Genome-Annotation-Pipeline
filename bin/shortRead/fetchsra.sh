echo `hostname`
echo "Current dir=$PWD"

module load sratoolkit/2.8.1

# Script inputs, paths are given relative to Snakemake file
sra="$1"

# Running directory
dir="$2"
cd $dir

defline='@$sn[_$rn]/$ri'
script="fastq-dump --defline-seq '$defline' --split-files $sra"
eval "$script"

script="vdb-validate $sra"
eval "$script"

mv ${sra}_1.fastq raw_${sra}_1.fastq
mv ${sra}_2.fastq raw_${sra}_2.fastq
