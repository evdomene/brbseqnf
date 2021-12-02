#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --partition=test
#SBATCH --account=project_2002552

export TMPDIR=$PWD
export SINGULARITY_TMPDIR=$PWD
export SINGULARITY_CACHEDIR=$PWD
unset XDG_RUNTIME_DIR

# Activate  Nextflow on Puhti
module load bioconda
source activate nextflow

# Nextflow command here
nextflow run poolseq.nf -resume -profile singularity
