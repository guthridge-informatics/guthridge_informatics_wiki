#! /bin/bash -l

#SBATCH -J repeat
#SBATCH -o bcl2fastq_demux.log
#SBATCH --mail-user=miles-smith@omrf.org
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=64
#SBATCH --partition=serial
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16

module load bcl2fastq
bcl2fastq \
    --rnfolder-dir=$PWD/
    --output-dir=$PWD/fastqs
    --loading-threads 4
    --processing-threads 8
    --writing-threads 4
