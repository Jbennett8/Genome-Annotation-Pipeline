#!/bin/bash

genomeSize="$1"
Genome="$PWD/$2"
speciesGmap="$PWD/$3"
speciesTranscriptome="$PWD/$4"
relatedGmap="$PWD/$5"
relatedTranscriptome="$PWD/$6"


for i in {1,2,3}; do
  curDir="annotation/maker/single/round${i}"
  curOpts="$curDir/maker_opts.ctl"
  cp -v bin/annotation/maker/round${i}/*.ctl $curDir
  script="sed -i \"2c genome=$Genome\" $curOpts"
  echo $script && eval $script
  script="sed -i \"18c est_gff=$speciesGmap\" $curOpts"
  echo $script && eval $script
  if [ $relatedGmap ]; then
    script="sed -i \"19c altest_gff=$relatedGmap\" $curOpts"
    echo $script && eval $script
  fi
  if [ $i -gt 1 ]; then
    let prevRound=i-1
    previousMaker=annotation/maker/single/round${prevRound}/round${prevRound}.all.gff
    script="sed -i \"6c maker_gff=$previousMaker\" $curOpts"
    echo $script && eval $script
  fi
  if [ $genomeSize = \"small\" ]; then # use transcriptome fasta evidence as well
    script="sed -i \"16c est=$speciesTranscriptome\" $curOpts"
    echo $script && eval $script
    if [ $relatedTranscriptome ]; then
      script="sed -i \"17c altest=$relatedTranscriptome\" $curOpts"
      echo $script && eval $script
    fi
  fi
done

