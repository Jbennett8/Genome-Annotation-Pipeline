module load python/3.6.3
module load biopython/1.70
module load bamtools/2.5.1
module load blast/2.10.0
module load genomethreader/1.7.1
module unload perl
module load perl/5.28.1

# We have a rm -r command in this file, so many sure we dont have unset variables
set -u

## This script expects these programs to be in these specified folders
## If they are ever moved/updated, or if you want to use ones in your home directory update the paths below
#augustusPath="/labs/Wegrzyn/annotationtool/software/Augustus_3.4.0"
augustusPath="/labs/Wegrzyn/annotationtool/software/Augustus_3.3.3"
brakerPath="/labs/Wegrzyn/annotationtool/software/BRAKER_2.1.5/scripts"
cbdfastaPath="/labs/Wegrzyn/annotationtool/software/cdbfasta"
genemarkPath="/labs/Wegrzyn/annotationtool/software/gmes_linux_64"

export PATH=$brakerPath:$brakerPath/scripts:$PATH
export CDBTOOLS_PATH=$cbdfastaPath
export GENEMARK_PATH=$genemarkPath
export BAMTOOLS_PATH=/isg/shared/apps/bamtools/2.5.1/bin
export BLAST_PATH=/isg/shared/apps/blast/ncbi-blast-2.10.0+/bin
export SAMTOOLS_PATH=/isg/shared/apps/samtools/1.9/bin
export BLAST_PATH=/isg/shared/apps/blast/ncbi-blast-2.10.0+/bin
export ALIGNMENT_TOOL_PATH=/isg/shared/apps/gth/1.7.3/bin

export AUGUSTUS_BIN_PATH=$augustusPath/bin
export AUGUSTUS_SCRIPTS_PATH=$augustusPath/scripts
export AUGUSTUS_CONFIG_PATH=$PWD/bin/config # Uses the config within the snakemake directory, change if you want a specific species config file

## If this run fails due to license expiring, you can get a new one at 
## http://exon.gatech.edu/GeneMark/license_download.cgi
## Save in the same directory as Snakefile as gm_key_64
## This script saves this key to your home directory, as GeneMark expects
cp gm_key_64 $HOME/.gm_key

speciesName="$1" # name used for training
softmaskedGenome="$PWD/$2"
bam="$PWD/$3"
outDir="$4"
extraArgs="$5"

cores="20"

cd $outDir

mkdir -p tmp
export TMPDIR=$PWD/tmp

# Remove old species file, if you are re-running
if [[ -d $AUGUSTUS_CONFIG_PATH/species/$speciesName ]]; then rm -r $AUGUSTUS_CONFIG_PATH/species/$speciesName; fi

script="braker.pl --species=$speciesName --genome=$softmaskedGenome --bam=$bam --cores $cores --softmasking 1 --gff3 $extraArgs"
eval $script
