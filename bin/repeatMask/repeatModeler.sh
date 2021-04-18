#!/bin/bash
#SBATCH --job-name=repeatModeler
#SBATCH -o %x%j.out
#SBATCH -e %x%j.err
#SBATCH --ntasks=1 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=22
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=50G

# Inputs
file="$PWD/$1"
outDir="$PWD/$2"
maskType="$3" # Does not need to be provided
fd=$(dirname $file)
fn=$(basename $file)

# Parameters
cores="22"
export DATABASE="RepeatDatabase"


export DATADIR=$fd
export SEQFILE=$fn
WORKDIR=/scratch/$USER/repeatmodeler
mkdir -p $WORKDIR
cp $DATADIR/$SEQFILE $WORKDIR
cd $WORKDIR

module load RepeatModeler/2.01
module load rmblastn/2.2.28
module unload perl/5.28.0
module load perl/5.24.0
export PERL5LIB=/UCHC/PublicShare/szaman/perl5/lib/perl5/

baseName=$(basename $outDir)

BuildDatabase -name $DATABASE -engine ncbi $SEQFILE
if [[ $baseName = 'genome' || $Masktype = 'braker' ]]; then
  nice -n 10 RepeatModeler -engine ncbi -pa $cores -database $DATABASE
elif [[ $baseName = 'maker' || $Masktype = 'maker' ]]; then
  nice -n 10 RepeatModeler -engine ncbi -pa $cores -database $DATABASE -LTRStruct
else
  echo "Masktype $Masktype or the end of path $outDir not recognized, should be either 'braker' or 'maker', or 'genome' or 'maker'"
  exit 1
fi
rsync -a ./consensi.fa.classified $DATADIR/$SEQFILE.consensi.fa.classified

# Copy repeat lib to genome folder
cd  "$(\ls -1dt ./*/ | head -n 1)"
cp consensi.fa.classified $outDir
