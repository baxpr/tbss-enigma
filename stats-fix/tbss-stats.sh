#!/usr/bin/env bash
#
# Inputs
#
#     img_dir      MNI resource of tbss-enigma_v2
#     src_dir      Location of this script
#     out_dir

export img_dir=/INPUTS/MNI
export src_dir=/opt/tbss-enigma
export out_dir=/OUTPUTS

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --img_dir)      export img_dir="$2";      shift; shift ;;
        --src_dir)      export src_dir="$2";      shift; shift ;;
        --out_dir)      export out_dir="$2";      shift; shift ;;
        *) echo "Input ${1} not recognized"; shift ;;
    esac
done

# fslstats ROI extraction using skeletonized ROIs
cd "${img_dir}"
for im in fa md ad rd; do
    fslstats \
        -K "${src_dir}/stats-fix/skeletonized_roi.nii.gz" \
        "${im}_regWarped" \
        -m \
        > "${out_dir}/roi_mean_${im}.txt"
    fslstats \
        -K "${src_dir}/enigma/ENIGMA_DTI_FA_skeleton_mask.nii.gz" \
        "${im}_regWarped" \
        -m \
        > "${out_dir}/skeleton_mean_${im}.txt"
done

# ROI volumes
fslstats \
    -K "${src_dir}/stats-fix/skeletonized_roi.nii.gz" \
    "${src_dir}/stats-fix/skeletonized_roi.nii.gz" \
    -v \
    > "${out_dir}/roi_volume.txt"
fslstats \
    -K "${src_dir}/enigma/ENIGMA_DTI_FA_skeleton_mask.nii.gz" \
    "${src_dir}/enigma/ENIGMA_DTI_FA_skeleton_mask.nii.gz" \
    -v \
    > "${out_dir}/skeleton_volume.txt"


# Reformat stats to friendly csv
generate_roi_table.py \
    --txt_dir "${out_dir}" \
    --lut "${src_dir}/enigma/ROIextraction_info/ENIGMA_look_up_table.txt"

