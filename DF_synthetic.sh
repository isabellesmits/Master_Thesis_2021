#!/bin/bash -l

#PBS -l walltime=23:59:00
#PBS -L tasks=28:lprocs=1

#DoubletFinder script

module load R
module load atools/torque

cd "$PBS_O_WORKDIR"

source <(aenv --data excel_parameters_all.csv)

Rscript /scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5/DF_synthetic.R ${method} ${percentage} ${replicate}