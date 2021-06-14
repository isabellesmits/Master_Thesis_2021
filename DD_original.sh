#!/bin/bash -l

#PBS -l walltime=00:59:00
#PBS -L tasks=28:lprocs=1

#DoubletDecon script

module load R

module load atools/torque

cd "$PBS_O_WORKDIR"
source <(aenv --data parameters_diploid_original.csv)

Rscript /scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/DD_original.R ${dataset} ${replicate}
