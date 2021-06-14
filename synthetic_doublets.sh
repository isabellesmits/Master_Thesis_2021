#!/bin/bash -l

#PBS -l walltime=23:59:00
#PBS -L tasks=28:lprocs=1

module load Python/3

dir=/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_5

cd $dir


mkdir synthetic_${method}/${percentage}percent/

mkdir synthetic_${method}/${percentage}percent/${percentage}_${replicate}/

mkdir synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix_unzipped/

synthetic_${method}/synthetic_doublets.py -i original/matrix_all/ -o synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix_unzipped/ -p ${percentage} -m ${method}

mkdir synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix/

cp -r ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix_unzipped/* ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix/

cd ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix/

gzip *

cd $dir

mkdir ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix_all/

cp -r ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix/* ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix_all/

cp -r ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix_unzipped/* ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/matrix_all/

mkdir ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/counts_method/

mkdir ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/DoubletDecon/

mkdir ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/Scrublet/

mkdir ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/Solo/

mkdir ${dir}/synthetic_${method}/${percentage}percent/${percentage}_${replicate}/DoubletFinder/
