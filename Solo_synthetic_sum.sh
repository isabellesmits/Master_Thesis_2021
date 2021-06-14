#!/bin/bash -l

#PBS -l walltime=71:59:00
#PBS -L tasks=1:lprocs=1

module load atools/torque

module load Python/3

#set submitdirectory in order to load right csv-file with aenv
cd ${PBS_O_WORKDIR} 

export PYTHONPATH="/scratch/antwerpen/grp/aitg/jcdujardin/scrnaseq/software/python_lib/lib/python3.8/site-packages/:${PYTHONPATH}"

#specificy location where Solo was downloaded
solodir="/scratch/antwerpen/grp/aitg/jcdujardin/scrnaseq/software/python_lib/bin"


#load csv-file that contains parameters used in the script below
source <(aenv --data excel_parameters_solo_sum.csv)


#make variable to shorten path
thesmain=$VSC_SCRATCH/master_thesis/leishmania/diploid/dataset_5

#idem
thesmat=${thesmain}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix_all

cp ${thesmat}/features.tsv ${thesmat}/genes.tsv
cp ${thesmat}/barcodes.tsv ${thesmat}/barcodes_backup.tsv


#Run Solo
modelfile=/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5/model_json_file.json
outputdir=${thesmain}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/Solo/

${solodir}/solo -t sum ${modelfile} ${thesmat}/ -o ${outputdir} --set-reproducible-seed 1

