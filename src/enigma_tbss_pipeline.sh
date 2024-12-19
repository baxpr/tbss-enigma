#!/usr/bin/env bash
#
# Reference: ../enigma/ENIGMA_TBSS_protocol_USC.pdf
#   (original source https://enigma.ini.usc.edu/wp-content/uploads/DTI_Protocols/ENIGMA_TBSS_protocol_USC.pdf)

fa_niigz=../INPUTS/dwmri_tensor_fa.nii.gz
out_dir=../OUTPUTSe
enigma_dir=../enigma

# (1) ENIGMA-DTI template FA map, edited skeleton, masks and corresponding distance map
#     have been copied to ../enigma

# (2) Copy all FA images into a working directory and change to that directory
#     so future commands work correctly (e.g. FA subdir is assumed by tbss commands)
cd "${out_dir}" || exit 1
cp "${fa_niigz}" fa.nii.gz

# (3) Erode FA image slightly with FSL
#     Eroded FA image will be ${out_dir}/FA/fa_FA.nii.gz
#     FA mask will be ${out_dir}/FA/fa_FA_mask.nii.gz
cd "${out_dir}"
tbss_1_preproc fa.nii.gz

# (4) Register FA image to template
#     Must be run from the working dir
tbss_2_reg -t "${enigma_dir}"/ENIGMA_DTI_FA.nii.gz
#tbss_2_reg -T
tbss_3_postreg -T

# (5), (6), (7) Remask and recompute distance map with new mask, if needed

# (8) TBSS projection / skeletonize
#tbss_skeleton \
#    -i ./FA_individ/${subj}/FA/${subj}_masked_FA.nii.gz \
#    -p 0.049 /enigmaDTI/TBSS/ENIGMA_targets_edited/mean_FA_skeleton_mask_dst \
#    ${FSLPATH}/data/standard/LowerCingulum_1mm.nii.gz \
#    ./FA_individ/${subj}/FA /${subj}_masked_FA.nii.gz \
#    ./FA_individ/${subj}/stats/${subj}_masked_FAske l.nii.gz \
#    -s /enigmaDTI/TBSS/ENIGMA_targets_edited/mean_FA_skeleton_mask.nii.gz


