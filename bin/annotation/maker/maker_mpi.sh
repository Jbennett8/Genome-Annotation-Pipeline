#!/bin/bash
#SBATCH --job-name=maker_mpi
#SBATCH -o %x%j.out
#SBATCH -e %x%j.err
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=32
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mem=10G

#EST: Trinity, gff from gth added related species
module load perl/5.28.1
module load mpich/3.4.1

makerPath="/labs/Wegrzyn/annotationtool/software/maker-3.01.03"
export PATH=$makerPath/bin:$PATH

name="$1" #iter run
outDir="$2" #outDir is expected to have all 3 .ctl files

cd $outDir

mpiexec -n 10 maker maker_opts.ctl maker_bopts.ctl maker_exe.ctl -base $name
