#!/bin/bash
 
module load perl/5.28.1

augustusPath="/labs/Wegrzyn/annotationtool/software/Augustus_3.4.0"

export PATH=$augustusPath/bin:$augustusPath/scripts:$PATH
export AUGUSTUS_BIN_PATH=$augustusPath/bin
export AUGUSTUS_CONFIG_PATH=$PWD/bin/config # Uses the config within the snakemake directory, change if you want a specific species config file

makerGff="$PWD/$1"
softmaskedGenome="$PWD/$2"
speciesName="$3" # Careful to not overwrite species names used for other things, like braker. A good idea is using something like ginkgo_biloba_maker_first
makerRound="$4" #first_iter, second_iter, etc
outDir="$5"

cd $outDir

if [[ -d $AUGUSTUS_CONFIG_PATH/species/$speciesName ]]; then rm -r $AUGUSTUS_CONFIG_PATH/species/$speciesName; fi

#take only the maker annotations
filteredMakerName="maker_only.gff"
awk '{if ($2=="maker") print }' $makerGff > $filteredMakerName

gff2gbSmallDNA.pl $filteredMakerName $softmaskedGenome 1000 ${makerRound}.gb

randomSplit.pl ${makerRound}.gb 100

new_species.pl --species=$speciesName

etraining --species=$speciesName --stopCodonExcludedFromCDS=true ${makerRound}.gb.train
augustus --species=$speciesName ${makerRound}.gb.test | tee test.out

#evaluate the results 
grep -A 22 Evaluation test.out | awk {print $1} > eval_test.out

# optimize the model. this step could take a very long time
optimize_augustus.pl --species=$speciesName --cpus=24 --kfold=24 ${makerRound}.gb.train

#train again
etraining --species=$speciesName ${makerRound}.gb.train
augustus --species=$speciesName ${makerRound}.gb.test | tee optimizedtest.out
