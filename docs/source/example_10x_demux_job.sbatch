#! /bin/bash -l

#SBATCH --job-name=demux
#SBATCH --output=demux.log
#SBATCH --mail-user={YOUR_EMAIL_HERE}@omrf.org
#SBATCH --mail-type=END,FAIL
#SBATCH --partition=serial
#SBATCH --mem=64G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8

export _JAVA_OPTIONS='-Xmx64G -Xms4G -XX:+UseParallelGC -XX:ParallelGCThreads=8'

apptainer run \
    --bind /s/guth-aci/var:/var \
    --bind /s/guth-aci:/s/guth-aci \
    /Volumes/guth_aci_informatics/software/bclconvert-4.1.7.sif \
    bcl-convert \
    --output-directory /s/guth-aci/${PROJECT}/data/raw/fastqs/${RUN_NAME} \
    --bcl-input-directory /s/guth-aci/${PROJECT}/data/raw/bcls/${RUN_NAME} \
    --sample-sheet /s/guth-aci/${PROJECT}/metadata/${RUN_NAME}/sample_sheet.csv \
    --force \
    --bcl-sampleproject-subdirectories true