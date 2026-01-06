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
#    fslstats \
#        -K "${src_dir}"/skeletonized_roi.nii.gz \
#        ${im}_regWarped \
#        -m \
#        > "${out_dir}"/roi_mean_${im}.txt
#
# ROIs 1, 2 are missing in the ROI description file ENIGMA_look_up_table.txt.
# These are (1) cerebellar white matter and (2) something in midbrain. They
# are removed here.

import argparse
import os
import pandas

parser = argparse.ArgumentParser()
parser.add_argument('--txt_dir', required=True)
parser.add_argument('--lut', required=True)
args = parser.parse_args()

roilist = pandas.read_csv(args.lut, sep='\t', names=['label', 'roi', 'roi_long'], usecols=[0, 1, 3])
skelframe = pandas.DataFrame([{'label': 99, 'roi': 'FULLSKEL', 'roi_long': 'Full skeleton'}])
roilist = pandas.concat([roilist, skelframe], ignore_index=True)

favals = pandas.read_csv(os.path.join(args.txt_dir, 'roi_mean_fa.txt'), names=['fa'])
favals['label'] = range(1, favals.shape[0]+1)
skelfa = pandas.read_csv(os.path.join(args.txt_dir, 'skeleton_mean_fa.txt'), names=['fa'])
skelfa['label'] = 99
favals = pandas.concat([favals, skelfa], ignore_index=True)

mdvals = pandas.read_csv(os.path.join(args.txt_dir, 'roi_mean_md.txt'), names=['md'])
mdvals['label'] = range(1, mdvals.shape[0]+1)
skelmd = pandas.read_csv(os.path.join(args.txt_dir, 'skeleton_mean_md.txt'), names=['md'])
skelmd['label'] = 99
mdvals = pandas.concat([mdvals, skelmd], ignore_index=True)

rdvals = pandas.read_csv(os.path.join(args.txt_dir, 'roi_mean_rd.txt'), names=['rd'])
rdvals['label'] = range(1, rdvals.shape[0]+1)
skelrd = pandas.read_csv(os.path.join(args.txt_dir, 'skeleton_mean_rd.txt'), names=['rd'])
skelrd['label'] = 99
rdvals = pandas.concat([rdvals, skelrd], ignore_index=True)

advals = pandas.read_csv(os.path.join(args.txt_dir, 'roi_mean_ad.txt'), names=['ad'])
advals['label'] = range(1, advals.shape[0]+1)
skelad = pandas.read_csv(os.path.join(args.txt_dir, 'skeleton_mean_ad.txt'), names=['ad'])
skelad['label'] = 99
advals = pandas.concat([advals, skelad], ignore_index=True)

volvals = pandas.read_csv(os.path.join(args.txt_dir, 'roi_volume.txt'), sep=' ', usecols=[1], names=['vol_mm3'])
volvals['label'] = range(1, volvals.shape[0]+1)
skelvol = pandas.read_csv(os.path.join(args.txt_dir, 'skeleton_volume.txt'), sep=' ', usecols=[1], names=['vol_mm3'])
skelvol['label'] = 99
volvals = pandas.concat([volvals, skelvol], ignore_index=True)


data = roilist.merge(favals, how='left', on='label')
data = data.merge(mdvals, how='left', on='label')
data = data.merge(rdvals, how='left', on='label')
data = data.merge(advals, how='left', on='label')
data = data.merge(volvals, how='left', on='label')

data.to_csv(os.path.join(args.txt_dir, 'extracted_roi_means.csv'), index=False)

