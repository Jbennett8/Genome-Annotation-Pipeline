module load busco/4.1.2

buscoLineage="$1"
buscoDir=$PWD/metrics/busco
outDir=$PWD/report/plots
buscoFilename=short_summary.specific.${buscoLineage}.busco_o.txt
prefix=short_summary.specific.${buscoLineage}

# If you want more runs to be included in the report, add them here

# Genome BUSCO
cp $buscoDir/genome/busco_o/$buscoFilename $buscoDir/summaries/${prefix}.genome.txt

# Braker BUSCO's
for i in {1..4};do
  cp $buscoDir/braker$i/busco_o/$buscoFilename $buscoDir/summaries/${prefix}.braker${i}.txt

# Run BUSCO plotting util
cd $outDir
mv $buscoDir/summaries/busco_figure.png ./
generate_plot.py -wd $buscoDir/summaries
