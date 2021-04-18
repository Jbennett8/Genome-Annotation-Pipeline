module load genomethreader/1.7.1
module load genometools/1.5.10

filteredPeptide="$PWD/$1"
softmaskedGenome="$PWD/$2"
outDir="$3"

cd $outDir

script="gt seqtransform -addstopaminos $filteredPeptide"
eval $script

gmapOut="gth.gff3"

script="gth -genomic $softmaskedGenome -protein $filteredPeptide \
  -gff3out \
  -startcodon \
  -gcmincoverage 80 \
  -finalstopcodon \
  -introncutout \
  -dpminexonlen 20 \
  -skipalignmentout \
  -o $gmapOut \
  -force \
  -gcmaxgapwidth 1000000"
eval $script
