#!/usr/bin/env python3
#
# Combine fslstats output with ENIGMA JHU ROI list to produce a readable csv.
# Assumes 48 ROIs exist and are listed in order in the fslstats output file.
# Discards first two ROIs (1, 2) because we don't have labels for those.
#
# Specifically tuned for ENIGMA ROI protocol label file ENIGMA_look_up_table.txt
# and label image JHU-WhiteMatter-labels-1mm.nii.gz
#
# The FA and MD csvs come from fslstats like
#  fslstats \
#      -K ${enigma_dir}/ROIextraction_info/JHU-WhiteMatter-labels-1mm.nii.gz \
#      fa_regWarped \
#      -m \
#      > roi_mean_FA.csv
#
# ROIs 1, 2 are missing in the ROI description file ENIGMA_look_up_table.txt.
# These are (1) cerebellar white matter and (2) something in midbrain. They
# are removed here.

import argparse
import pandas

parser = argparse.ArgumentParser()
parser.add_argument('--fa_csv', required=True)
parser.add_argument('--md_csv', required=True)
parser.add_argument('--rd_csv', required=True)
parser.add_argument('--ad_csv', required=True)
parser.add_argument('--lut', required=True)
args = parser.parse_args()

roilist = pandas.read_csv(args.lut, sep='\t', names=['label', 'roi', 'roi_long'], usecols=[0, 1, 3])

favals = pandas.read_csv(args.fa_csv, names=['fa'])
favals['label'] = range(1, favals.shape[0]+1)

mdvals = pandas.read_csv(args.md_csv, names=['md'])
mdvals['label'] = range(1, mdvals.shape[0]+1)

rdvals = pandas.read_csv(args.rd_csv, names=['rd'])
rdvals['label'] = range(1, rdvals.shape[0]+1)

advals = pandas.read_csv(args.ad_csv, names=['ad'])
advals['label'] = range(1, advals.shape[0]+1)

data = roilist.merge(favals, how='left', on='label')
data = data.merge(mdvals, how='left', on='label')
data = data.merge(rdvals, how='left', on='label')
data = data.merge(advals, how='left', on='label')

data.to_csv('extracted_roi_means.csv', index=False)

