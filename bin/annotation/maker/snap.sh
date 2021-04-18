#!/bin/bash
 
module load perl/5.28.1

snapPath="/labs/Wegrzyn/annotationtool/software/snap"
makerPath="/labs/Wegrzyn/annotationtool/software/maker-3.01.03/bin/maker"

export PATH=$snapPath:$PATH

MAKERDIR=/home/FCAM/vvuruputoor/maker/bin
MAKERROUNDDIR=/labs/Wegrzyn/annotationtool/testSpecies/model/elegans/analysis/annotation_new_version/maker/1_round_maker
SNAPDIR=/home/FCAM/vvuruputoor/maker/exe/snap

${MAKERDIR}/maker2zff ${MAKERROUNDDIR}/first_iter.all.gff
${SNAPDIR}/fathom -categorize 1000 genome.ann genome.dna
${SNAPDIR}/fathom -export 1000 -plus uni.ann uni.dna
${SNAPDIR}/forge export.ann export.dna
${SNAPDIR}/hmm-assembler.pl first_iter . > first_iter.hmm
