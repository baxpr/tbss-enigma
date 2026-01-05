Post-processing for tbss-enigma stats - fixes a bug in ROI signal extraction.

Extracts FA, MD, RD, AD from correctly skeletonized ROIs.

Skeletonized ROIs in MNI space created via

    fslmaths \
        ../enigma/ENIGMA_DTI_FA_skeleton_mask.nii.gz \
        -bin \
        -mul ../enigma/ROIextraction_info/JHU-WhiteMatter-labels-1mm.nii.gz \
        skeletonized_roi

