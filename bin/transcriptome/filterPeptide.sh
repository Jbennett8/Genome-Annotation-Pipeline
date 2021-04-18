module load seqtk/1.2

filteredCentroidsFile="$PWD/$1"
frameselectedPeptideFile="$PWD/$2"
outDir="$3"

cd $outDir

outName="filtered.pep"
nameList="filter300nameList.txt"

# Grab headers from centroids file
sed -e 's/>\(.*\)$/\1/;t;d' $filteredCentroidsFile > "$nameList"

# Remove extraneous info from peptide file, keep simple headers only
sed -e 's/\s.*$//' $frameselectedPeptideFile > tmp.pep

# Grab the same proteins corresponding to the genes you have in your filtered centroids file
seqtk subseq tmp.pep $nameList > $outName
