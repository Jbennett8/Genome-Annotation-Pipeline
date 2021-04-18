module load fastqc/0.11.7

input_dir="$PWD/$1"
sra_file_p1="$2"
sra_file_p2="$3"
output_dir="$4"

cd $output_dir
script="fastqc -t 1 -o $PWD $input_dir/$sra_file_p1 $input_dir/$sra_file_p2"
eval "$script"
