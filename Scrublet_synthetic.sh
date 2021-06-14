#!/bin/bash -l

#PBS -l walltime=23:59:00
#PBS -L tasks=28:lprocs=1

module load Python/3

export PYTHONPATH="/scratch/antwerpen/grp/aitg/jcdujardin/scrnaseq/software/python_lib/lib/python3.8/site-packages/:${PYTHONPATH}"

module load atools/torque

cd "$PBS_O_WORKDIR"
source <(aenv --data excel_parameters_all.csv)

/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5/Scrublet_synthetic.py ${method} ${percentage} ${replicate}