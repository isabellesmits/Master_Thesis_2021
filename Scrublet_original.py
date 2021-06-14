#!/usr/bin/env python3
#script Scrublet

import sys
import scrublet as scr
import scipy.io
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd

args = sys.argv
dataset = args[1]
replicate= args[2]


basedir = '/scratch/antwerpen/206/vsc20688/master_thesis/leishmania/diploid/dataset_' + str(dataset) + '/'



plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = 'Arial'
plt.rc('font', size = 14)
plt.rcParams['pdf.fonttype']= 42

input_dir = basedir + 'original/matrix_all'
counts_matrix = scipy.io.mmread(input_dir +'/matrix.mtx.gz').T.tocsc()
genes = np.array(scr.load_genes(input_dir + '/features.tsv', delimiter = "\t", column =1))
print('Counts matrix shape: {} rows, {} columns'.format(counts_matrix.shape[0], counts_matrix.shape[1]))


print('Number of genes in gene list: {}'.format(len(genes)))

scrub = scr.Scrublet(counts_matrix, expected_doublet_rate = 0.06)
doublet_scores, predicted_doublets = scrub.scrub_doublets(min_counts=2, min_cells=3, min_gene_variability_pctl=85, n_prin_comps=30)
scrub.plot_histogram()
plt.savefig(basedir + 'original/Scrublet/run_' + str(replicate) + '/doublets.png')
scrub.set_embedding('UMAP', scr.get_umap(scrub.manifold_obs_, 10, min_dist=0.3))
scrub.plot_embedding('UMAP', order_points=True)
plt.savefig(basedir + 'original/Scrublet/run_' + str(replicate) + '/UMAP.png')
barcodes = pd.read_csv(input_dir + '/barcodes.tsv', header = None)
barcodes.iloc[predicted_doublets,]
predicted = barcodes.iloc[predicted_doublets,]
print(len(predicted))
#[186 rows x 1 columns]
predicted.to_csv(basedir + 'original/Scrublet/run_' + str(replicate) + '/predicted.csv', sep = ',', header=False)
