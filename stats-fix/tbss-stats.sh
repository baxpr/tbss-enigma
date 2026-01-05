#!/usr/bin/env bash
#
# Inputs
#
#     img_dir      MNI resource of tbss-enigma_v2
#     src_dir      Location of this script
#     out_dir

export img_dir=/INPUTS/MNI
export src_dir=/opt/tbss-enigma/stats-fix
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

cd "${img_dir}"
for im in fa md ad rd; do
    fslstats \
        -K "${src_dir}"/skeletonized_roi.nii.gz \
        ${im}_regWarped \
        -m \
        > "${out_dir}"/roi_mean_${im}.txt
done

