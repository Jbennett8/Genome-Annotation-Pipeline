module load trinity/2.8.5
module load bowtie2/2.3.4.3
module load samtools/1.10

PE_1="$PWD/$1"
PE_2="$PWD/$2"
out="$3"

cd $out

outname=trinity

# Uses normalization, in my experience many errors can be avoided by skipping this step and running the below command
#script="Trinity --seqType fq --left $PE_1 --right $PE_2 --min_contig_length 300 --output $outname --full_cleanup --max_memory 150G --CPU 20"

# Run this if zero reads make it to normalization step and you have double checked that your left + right read names match eachother except for the /1 and /2 at the end
script="Trinity --seqType fq --left $PE_1 --right $PE_2 --no_normalize_reads --min_contig_length 300 --output $outname --full_cleanup --max_memory 150G --CPU 20"
eval "$script"

# Add unique prefix to transcripts
outfile=trinity.Trinity.fasta
SraName=$(basename $out)
sed 's/>/>$SraName/g' $outfile > prefix.Trinity.fasta
