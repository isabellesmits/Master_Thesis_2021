#!/bin/bash -l

#PBS -l walltime=71:59:00
#PBS -L tasks=28:lprocs=1

#counts_method script

module load R
module load atools/torque

cd "$PBS_O_WORKDIR"

source <(aenv --data excel_parameters_all.csv)

Rscript /scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5/cm_synthetic.R ${method} ${percentage} ${replicate}