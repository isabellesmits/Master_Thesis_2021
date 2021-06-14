#!/usr/bin/env python3

import csv
import gzip
import os
import scipy.io
import sys
import pandas as pd
import random
import argparse
import numpy as np


parser = argparse.ArgumentParser(
        description="Script to create synthetic doublet files based on the output of CellRanger.")
parser.add_argument('-i', '--input_dir', required=True, type=str,
                    help="directory where the original output of Cell Ranger is stored. Should contain the features.tsv, barcodes.tsv and matrix.mtx.gz file. Only the latter one should be zipped")
parser.add_argument('-o', '--output_dir', required=True, type=str,
                    help="output directory where the output files with synthetic doulblets are stored. The IDs of the synthetic doublets are given in a separate files.")
parser.add_argument('-p', '--percentage', required=True, type=float,
                    help="percentage of the cells that should be converted to doublets. Should be an integer")
parser.add_argument('-m', '--method', required=False, type=str, default = "mean",
                    help="[mean] or [sum] or [delete] indicate whether synthetic doublets should be created by summing or averaging read counts from both cells. Delete is a special case where random cells are deleted, without creating any doublets")
parser.add_argument('-s', '--subset', required=False, type=int, default = 0,
                    help="temporary directory where the coverage files can be stored temporary")



args = parser.parse_args()
input_dir = args.input_dir
output_dir = args.output_dir
percentage_of_cells = args.percentage
method = args.method
subset_cells = args.subset

my_debug = 0



##### 1. readin in and subsetting the data #####

## Read in the data. Assumed that the three output files of cell ranger are all
## stored in the same directory, where the features.tsv and barcodes.tsv should
## *not* be zipped, while matrix.mtx.gz should be zipped. 

## reading in the matrix using the scipy command for reading in sparse
## matrices, and converting to normal matrix
print(f"\nreading in matrix file [{input_dir}/matrix.mtx.gz]")
mat = scipy.io.mmread(os.path.join(input_dir, "matrix.mtx.gz"))
my_debug and print(f"head of sparse matrix converted to regular matrix: {mat.todense()[:10,:10]}")
mat_full = mat.todense()


## read in the features.tsv file, in order to remove those genes for which
## no expression is found in any of the cells. Mainly a problem when subsetting
# the number of cells to a low number.
features_file = input_dir + 'features.tsv'
features = pd.read_csv(features_file, delimiter="\t", header=None)
my_debug and print(features)

## read in the barcodes file
barcodes_path = os.path.join(input_dir, "barcodes.tsv")
barcodes = [row[0] for row in csv.reader(open(barcodes_path, 'r'), delimiter="\t")]

## convert the full matrix into a data frame, and set the column names of
## this data frame to the barcodes 
pd_full = pd.DataFrame(mat_full)
pd_full.columns = barcodes


## the subset can be used to create a smaller dataset which can be used for 
## testing. In case subsset is defined, only a smaller amount of cells is 
## selected
if subset_cells > 0:
    barcodes = barcodes[0:subset_cells]
    pd_full = pd_full.iloc[:,0:subset_cells]



##### 2. create synthetic doulblets #####

## randomly select two barcodes and merge them into one barcode. Only the first
## barcode will be retained, the second barcode will be deleted from the cells

## random_cell_index is the number of cells from which you can sample. Based on 
## this number, two random numbers are sampled, and corresponding barcode looked up
random_cell_index = list(range(len(barcodes)))
my_debug and print(f"random cell index {random_cell_index}")


## set the parameters
counter =  0
doublets_to_add = int(percentage_of_cells*len(random_cell_index)/100)
print(f"\nsampling [{doublets_to_add}] cells from a total of [{len(random_cell_index)}] -- [{percentage_of_cells}%] using method [{method}]\n")

doublets_list = []
barcodes_to_be_removed = []

while counter < doublets_to_add:
    
    ## randomly select two barcodes, and remove them from the list of barcodes which 
    ## can be sampled. This prevents that the same barcode is sampled twice + prevents
    ## that a barcode is chosen which is already deleted. 
    random_cell_one = random.choice(random_cell_index)
    random_cell_index.remove(random_cell_one)
    random_cell_two = random.choice(random_cell_index)
    random_cell_index.remove(random_cell_two)
    random_barcode_one = barcodes[random_cell_one]
    random_barcode_two = barcodes[random_cell_two]
    
    print(f"creating synthetic doublet [{counter + 1}] combining {random_barcode_one} with {random_barcode_two}") 
    my_debug and print(f"creating synthetic doublet for :\n {pd_full[[random_barcode_one,random_barcode_two]].iloc[1:30,:]}")

    if method == "mean":
        
        ## take the mean value of the read count for both barcodes. 
        pd_full[[random_barcode_one]] = pd_full[[random_barcode_one,random_barcode_two]].mean(axis=1)
        
        ## try-out code to randomly add or subtract a value between -0.05 and 0.05 to 
        ## randomize the rouning. Default behavior of python is to always round to the 
        ## closest *even* integer
        random_df = pd.DataFrame(np.random.uniform(low=-0.05,high=0.05, size=len(pd_full[[random_barcode_one]])))
        pd_full[[random_barcode_one]] = pd_full[[random_barcode_one]].add(random_df.iloc[:,0], axis=0)
        my_debug and print(f"before rounding\n {pd_full[[random_barcode_one]].iloc[1:30]}")
    
        ## round the barcode to the closest even integer (default behavior of python). 
        pd_full[[random_barcode_one]] = round(pd_full[[random_barcode_one]])
        my_debug and print(f"after rounding\n {pd_full[[random_barcode_one]].iloc[1:30]}")

    elif method == "sum":
        # pd_full[[random_barcode_one]] = pd_full[[random_barcode_one,random_barcode_two]].sum(axis=1)
        pd_full[[random_barcode_one]] = pd_full[[random_barcode_one]].add(pd_full.loc[:,random_barcode_two], axis=0)
        my_debug and print(f"after summing\n {pd_full[[random_barcode_one]].iloc[1:30]}")

    elif method == "delete":
        my_debug and print(f"keep the original for barcode 1 and delete barcode 2\n {pd_full[[random_barcode_one]].iloc[1:30]}")

    
    ## remove the second barcode from the full data frame, but also from 
    ## the barcodes list, as this should not be in the final barcode list 
    pd_full.drop(random_barcode_two, axis=1, inplace=True)
    barcodes_to_be_removed.append(random_barcode_two)
       
    ## the the random barcode one to a list containing the full list of 
    ## doublet barcodes
    doublets_list.append(f"{random_barcode_one}\t{random_barcode_two}")
    counter = counter + 1



## remove the barcodes that have been deleted from the barcodes list
barcodes = [barcode for barcode in barcodes if barcode not in barcodes_to_be_removed]

## make sure that the full data frame is made of integers. Rounding 
## in some cases still return floating nubmers like xxx.0
pd_full = pd_full.astype(int)
my_debug and print(pd_full.shape)
my_debug and print(f"head of pd_full:\n{pd_full.head}")
my_debug and print(f"doublets_list: {doublets_list}")

## remove the features / genes which expression is 0 over all cells, and also select 
## only those features 
features_filtered = features.loc[pd_full.sum(axis=1) > 0,:]
pd_full = pd_full.loc[pd_full.sum(axis=1) > 0,:]

## print the header 
matrix_out_file = output_dir + "matrix.mtx"
# mtx_out = open(matrix_out_file, 'w')
# header_line_fixed = f"%%MatrixMarket matrix coordinate integer general\n%metadata_json: {{\"format_version\": 2, \"software_version\": \"3.0.2\"}}\n"
# my_debug and print(header_line_fixed)

## only count those genes for which at least one of the cells has a value 
## higher than 0. This is not a problem for Seurat, but migth be a problem
## for other tools like e.g. Solo or Scrublet.
# num_genes = sum(pd_full.sum(axis=1) > 0)
# num_cells = pd_full.shape[1]

## number of entries is the number of cells in the full matrix that is 
## larger than 0. This corresponds to the word count of the sparse matrix
## in the matrix.mtx minus 3 (3 = number of header lines)
# num_entries = int((pd_full > 0).sum().sum())
# header_line_stats = f"{num_genes} {num_cells} {num_entries}\n"
# mtx_out.write(header_line_fixed)
# mtx_out.write(header_line_stats)
# mxt_out.write("test2")


print(f"\nwriting down results to files in [{output_dir}]\n")

## print ouput using the specialized library to write out sparse matrices
## using scipy
sparse_matrix = scipy.sparse.csr_matrix(pd_full.values)
scipy.io.mmwrite(matrix_out_file, sparse_matrix)

# for cell_index in range(0,pd_full.shape[1]):
#     for gene_index in range(0,pd_full.shape[0]):
#         if pd_full.iloc[gene_index,cell_index] > 0:
#             out_line = f"{gene_index+1} {cell_index+1} {pd_full.iloc[gene_index,cell_index]}\n"
#             mtx_out.write(out_line)
            

## make barcode file 
barcodes_out = open(output_dir + "barcodes.tsv", 'w')
barcodes_out.write("\n".join(barcodes)+ "\n")
barcodes_out.close()

## barcodes that are now doublets 
barcodes_doublets_out = open(output_dir + "barcodes_doublets.tsv", 'w')
barcodes_doublets_out.write("\n".join(doublets_list) + "\n")
barcodes_doublets_out.close()

## create the features file - remove those features with a sum of 0
features_filtered.to_csv(output_dir + 'features.tsv', sep="\t", header=False, index=False)




