#!/usr/bin/env bash
#
# Two of the supplied template images do not have the qform/sform set
# correctly in the nifti header. Here we copy those from the FA image itself.

sform=$(fslorient -getsform ENIGMA_DTI_FA)
sformcode=$(fslorient -getsformcode ENIGMA_DTI_FA)
qform=$(fslorient -getqform ENIGMA_DTI_FA)
qformcode=$(fslorient -getqformcode ENIGMA_DTI_FA)

for f in ENIGMA_DTI_FA_mask.nii.gz ENIGMA_DTI_FA_skeleton_mask_dst.nii.gz; do
    cp ${f} ${f}.orig
    fslorient -setsform ${sform} ${f}
    fslorient -setsformcode ${sformcode} ${f}
    fslorient -setqform ${qform} ${f}
    fslorient -setqformcode ${qformcode} ${f}
done
