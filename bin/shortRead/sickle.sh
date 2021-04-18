inputDir="$PWD/$1"
rawReadName="$2"
outDir="$3"
minQuality="$4"
minLength="$5"

if [ -z "$minQuality" ];then
  minQuality=30
fi

if [ -z "$minLength" ];then
  minLength=50
fi

module load sickle/1.33

f1=raw_"${rawReadName}_1.fastq"
f2=raw_"${rawReadName}_2.fastq"

echo "$f1 $f2"

cd $outDir
script="sickle pe -f $inputDir/$f1 -r $inputDir/$f2 -t sanger -o trimmed_"$f1" -p trimmed_"$f2" -s single_trimmed_"${rawReadName}".fastq -q $minQuality -l $minLength"
eval "$script"

mv trimmed_$f1 trimmed_${rawReadName}_1.fastq
mv trimmed_$f2 trimmed_${rawReadName}_2.fastq

# Some attempts at fixing problematic read names for trinity, like @readname_F or @readname_forward paired with @readname_R or @readname_reverse
# Removes everything after an underline
sed -i 's/_.*/\/1/g' trimmed_${rawReadName}_1.fastq
sed -i 's/_.*/\/2/g' trimmed_${rawReadName}_2.fastq
