#!/usr/bin/env bash
#
# Reference: ../enigma/ENIGMA_TBSS_protocol_USC.pdf
#   (original source https://enigma.ini.usc.edu/wp-content/uploads/DTI_Protocols/ENIGMA_TBSS_protocol_USC.pdf)

# Inputs needed from entrypoint.sh
#   fa_niigz      Subject FA image
#   md_niigz      Subject MD image
#   rd_niigz      Subject RD image
#   ad_niigz      Subject AD image
#   v1_niigz      Subject V1 image
#   out_dir       Output/working directory
#   enigma_dir    Location of enigma files (template, skeleton, etc)
#   md_threshold  MD threshold to use for tighter brain mask


# (1) ENIGMA-DTI template FA map, edited skeleton, masks and corresponding distance map
#     should be in enigma_dir

# (2) Copy all needed images into a working directory and change to that directory
cd "${out_dir}" || exit 1
cp "${fa_niigz}" fa_unmasked.nii.gz
cp "${md_niigz}" md.nii.gz
cp "${rd_niigz}" rd.nii.gz
cp "${ad_niigz}" ad.nii.gz
cp "${v1_niigz}" v1.nii.gz
cp ${enigma_dir}/ENIGMA_DTI_FA.nii.gz                     template_FA.nii.gz
cp ${enigma_dir}/ENIGMA_DTI_FA_mask.nii.gz                template_mask.nii.gz
cp ${enigma_dir}/ENIGMA_DTI_FA_skeleton_mask.nii.gz       template_skeleton_mask.nii.gz
cp ${enigma_dir}/ENIGMA_DTI_FA_skeleton_mask_dst.nii.gz   template_skeleton_mask_dst.nii.gz

# (3) (SKIPPED, WITH ANTS) Erode FA image slightly for tbss_2_reg
#     Eroded FA image will be ${out_dir}/FA/fa_FA.nii.gz
#     FA mask will be ${out_dir}/FA/fa_FA_mask.nii.gz
#tbss_1_preproc fa.nii.gz

# (4) Register FA image to template

# Using TBSS scripts would be - must be run from the working dir
#tbss_2_reg -t "${enigma_dir}"/ENIGMA_DTI_FA.nii.gz
#tbss_2_reg -T
#tbss_3_postreg -T

# BUT we use ANTS - works much better.

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
    -o fa_reg

# Apply warp to other images (MD)
for im in md rd ad; do
antsApplyTransforms -v \
    -i "${im}".nii.gz \
    -r fa_regWarped.nii.gz \
    -t fa_reg1Warp.nii.gz -t fa_reg0GenericAffine.mat \
    -o "${im}"_regWarped.nii.gz
done


# Warp template skeleton to native space
antsApplyTransforms -v \
    -i template_skeleton_mask.nii.gz \
    -r fa_unmasked.nii.gz \
    -n NearestNeighbor \
    -t \[fa_reg0GenericAffine.mat,1\] -t fa_reg1InverseWarp.nii.gz \
    -o native_skeleton_mask.nii.gz

# Create skeleton-masked V1 image in native space
fslmaths native_skeleton_mask -bin -mul v1 skeleton_v1

# (5) (SKIPPED - we are using template) Remask if needed

# (6) (SKIPPED - we are using template) Compute distance maps
# Original command is
#    tbss_4_prestats -0.049
# But we will select out just the necessary bits from tbss_4_prestats

# Binarize the FA template skeleton
#fslmaths template_FA_skeleton -bin template_FA_skeleton_mask

# Create template distance map
#fslmaths template_FA_mask -mul -1 -add 1 -add template_FA_skeleton_mask template_FA_skeleton_mask_dst
#distancemap -i template_FA_skeleton_mask_dst -o template_FA_skeleton_mask_dst

# (7) (SKIPPED - single subj pipeline) Reorganize files to parallelize for multiple subjs

# (8) Project warped subject FA data onto skeleton
# What is the input image supposed to be? It affects resulting values.
# ENIGMA protocol step 8 is using the subject FA as input image, with 
# -s option to specify skeleton (ENIGMA_TBSS_protocol_USC.pdf).
tbss_skeleton \
    -i fa_regWarped \
    -p 0 \
    template_skeleton_mask_dst \
    ${FSLDIR}/data/standard/LowerCingulum_1mm \
    fa_regWarped \
    fa_regWarped_skeletonised \
    -s template_skeleton_mask

# Bring along other stats
for im in md ad rd; do
    tbss_skeleton \
        -i "${im}"_regWarped \
        -p 0 \
        template_skeleton_mask_dst \
        ${FSLDIR}/data/standard/LowerCingulum_1mm \
        fa_regWarped \
        "${im}"_regWarped_skeletonised \
        -a "${im}"_regWarped \
        -s template_skeleton_mask
done


# ROI extraction

# Mean FA in entire skeleton
mask_mean_FA=$(fslstats -K template_skeleton_mask fa_regWarped -m)
echo "Mean FA in skeleton: ${mask_mean_FA}"

# Mean stats in skeleton (non-zero voxels) in JHU ROIs
for im in fa md ad rd; do
    fslstats \
        -K ${enigma_dir}/ROIextraction_info/JHU-WhiteMatter-labels-1mm.nii.gz \
        "${im}"_regWarped \
        -m \
        > roi_mean_"${im}".csv
done
