#!/bin/bash
#SBATCH --job-name=maker
#SBATCH -o %x%j.out
#SBATCH -e %x%j.err
#SBATCH --ntasks=1 
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=20G

module load perl/5.28.1

makerPath="/labs/Wegrzyn/annotationtool/software/maker-3.01.03"
export PATH=$makerPath/bin:$PATH

name="maker" # all output gff will be maker.all.gff
outDir="$1"
cores="$2"

cd $outDir
    
script="sed -i \"54c cpus=$cores\" maker_opts.ctl"
echo $script && eval $script

maker maker_opts.ctl maker_bopts.ctl maker_exe.ctl -base $name

maker -base ${name} -fix_nucleotides -dsindex
gff3_merge  -d ${name}.maker.output/${name}_master_datastore_index.log
fasta_merge -d ${name}.maker.output/${name}_master_datastore_index.log

#grep -c '>' ${name}.all.gff | awk {"print $1"} >  gene_annotations.txt
#grep -c -P "\tgene\t" ${name}.all.gff | awk {"print $1"} > number_of_genes.txt
