trinityFasta="$PWD/$1"
outDir="$2"

cd $outDir

module load hmmer/3.1b2 
module load perl/5.24.0
module load TransDecoder/5.3.0

###Training with longest ORFs
TransDecoder.LongOrfs -t $trinityFasta #takes 2 mins

###generic prediction only reporting best hit
mkdir -p bestHit

TransDecoder.Predict -t $trinityFasta --single_best_only
mv *.transdecoder.* bestHit


