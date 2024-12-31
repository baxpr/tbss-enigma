#!/usr/bin/env python
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
parser.add_argument('--lut', required=True)
args = parser.parse_args()

roilist = pandas.read_csv(args.lut, sep='\t', header=0, names=['label', 'roi', 'roi_long'], usecols=[0, 1, 3])

roivals = pandas.read_csv(args.fa_csv, names=['fa'])
roivals['label'] = range(1, roivals.shape[0]+1)

data = roilist.merge(roivals, how='left', on='label')

data.to_csv('extracted_roi_means.csv', index=False)

