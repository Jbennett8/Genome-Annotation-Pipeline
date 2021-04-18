module load usearch/9.0.2132

cdsFile="$PWD/$1"
scriptDir="$PWD/$2"
outDir="$3"

cd $outDir

script="usearch --cluster_fast $cdsFile --centroids centroids --uc centroids.uc --id 0.98"
eval $script

# filter genes < 300bp from centroids file
module load biopython/1.70
module load numpy/1.6.2

script="$scriptDir/aux/./filterLen.py --fasta centroids --length 300 --out centroids-filtered"
eval $script


