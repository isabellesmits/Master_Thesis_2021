#!/bin/bash -l

#PBS -l walltime=00:59:00
#PBS -L tasks=1:lprocs=1

module load atools/torque

module load Python/3

#go to the submitdirectory in order to load the right csv-file with aenv
cd ${PBS_O_WORKDIR} 

export PYTHONPATH="/scratch/antwerpen/grp/aitg/jcdujardin/scrnaseq/software/python_lib/lib/python3.8/site-packages/:${PYTHONPATH}"

#specificy the library where Solo is downloaded
solodir="/scratch/antwerpen/grp/aitg/jcdujardin/scrnaseq/software/python_lib/bin"


#load csv-file containing parameters used in the script below
source <(aenv --data parameters_Solo_original.csv)


#make variable to shorten path
thesmain=$VSC_SCRATCH/master_thesis/leishmania/diploid/dataset_${dataset}

#idem
thesmat=${thesmain}/original/matrix_all

cp ${thesmat}/features.tsv ${thesmat}/genes.tsv
cp ${thesmat}/barcodes.tsv ${thesmat}/barcodes_backup.tsv


#Run Solo
modelfile=/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/model_json_file.json
outputdir=${thesmain}/original/Solo_${method}/run_${replicate}

${solodir}/solo -t ${method} ${modelfile} ${thesmat}/ -o ${outputdir} --set-reproducible-seed 1

