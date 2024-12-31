#!/usr/bin/env bash
#
# Reference: ../enigma/ENIGMA_TBSS_protocol_USC.pdf
#   (original source https://enigma.ini.usc.edu/wp-content/uploads/DTI_Protocols/ENIGMA_TBSS_protocol_USC.pdf)

export PATH=/usr/local/ants-2.5.4/bin:${PATH}

fa_niigz=../INPUTS/dwmri_tensor_fa.nii.gz
md_niigz=../INPUTS/dwmri_tensor_md.nii.gz
out_dir=../OUTPUTSants
enigma_dir=../enigma

md_threshold=0.0003

# (1) ENIGMA-DTI template FA map, edited skeleton, masks and corresponding distance map
#     have been copied to ../enigma

# (2) Copy all needed images into a working directory and change to that directory
#     so future commands work correctly (e.g. FA subdir is assumed by tbss commands)
cd "${out_dir}" || exit 1
cp "${fa_niigz}" fa_unmasked.nii.gz
cp "${md_niigz}" md.nii.gz
cp ${enigma_dir}/ENIGMA_DTI_FA.nii.gz                     template_FA.nii.gz
cp ${enigma_dir}/ENIGMA_DTI_FA_mask.nii.gz                template_mask.nii.gz
cp ${enigma_dir}/ENIGMA_DTI_FA_skeleton_mask.nii.gz       template_skeleton_mask.nii.gz
cp ${enigma_dir}/ENIGMA_DTI_FA_skeleton_mask_dst.nii.gz   template_skeleton_mask_dst.nii.gz

# (3) Erode FA image slightly for tbss_2_reg
#     Eroded FA image will be ${out_dir}/FA/fa_FA.nii.gz
#     FA mask will be ${out_dir}/FA/fa_FA_mask.nii.gz
#tbss_1_preproc fa.nii.gz

# (4) Register FA image to template

# Using TBSS scripts - must be run from the working dir
#tbss_2_reg -t "${enigma_dir}"/ENIGMA_DTI_FA.nii.gz
#tbss_2_reg -T
#tbss_3_postreg -T

# Using ANTS 2.5.4 - works much better.
# FIXME we may need to apply the warp to MD etc (antsApplyTransforms)

# First make a tighter/more accurate subject mask using thresholded MD image
fslmaths "${md_niigz}" -thr ${md_threshold} -bin mask

# Mask the input FA image
fslmaths fa_unmasked -mas mask fa

# Do the registration with ANTS
antsRegistrationSyN.sh \
    -d 3 -y 1 \
    -f template_FA.nii.gz \
    -m fa.nii.gz \
    -x template_mask.nii.gz,mask.nii.gz \
    -o fa_reg \
    &> antsregistration.log

# Need to do some of the stuff in tbss_3_postreg now. It is 
# intended for a custom multi-subject template and it
#   - Chooses a target among all subject images
#   - Registers all to target
#   - Registers target to MNI space
#   - Carries along other subject images to MNI space
#   - Computes all subj mean FA and mask from it
#   - Creates skeleton of mean FA within the mask
#
# But we only have one subj image and a template already in MNI space.
# So we will use default/standard FA and skeleton which are
#    $FSLDIR/data/standard/FMRIB58_FA_1mm.nii.gz
#    $FSLDIR/data/standard/FMRIB58_FA-skeleton_1mm.nii.gz
#    And we got the mask above by binarizing the template FA.

# (5) Remask if needed

# (6) Compute distance maps
# Original command is
#    tbss_4_prestats -0.049
# But we will select out just the necessary bits from tbss_4_prestats

# Binarize the FA template skeleton
#fslmaths template_FA_skeleton -bin template_FA_skeleton_mask

# Create template distance map
#fslmaths template_FA_mask -mul -1 -add 1 -add template_FA_skeleton_mask template_FA_skeleton_mask_dst
#distancemap -i template_FA_skeleton_mask_dst -o template_FA_skeleton_mask_dst

# (7) Reorganize files to parallelize for multiple subjs

# (8) Project warped subject FA data onto skeleton
# What is the input image supposed to be? It affects resulting values.
# ENIGMA protocol step 8 is using the subject FA image with -s option (ENIGMA_TBSS_protocol_USC.pdf).
tbss_skeleton \
    -i fa_regWarped \
    -p 0 \
    template_skeleton_mask_dst \
    ${FSLDIR}/data/standard/LowerCingulum_1mm \
    fa_regWarped \
    fa_regWarped_skeletonised \
    -s template_skeleton_mask

