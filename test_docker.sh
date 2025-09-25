#!/usr/bin/env bash

docker run \
    --mount type=bind,src=$(pwd -P)/INPUTS,dst=/INPUTS \
    --mount type=bind,src=$(pwd -P)/OUTPUTS,dst=/OUTPUTS \
    baxterprogers/tbss-enigma:test \
    --fa_niigz /INPUTS/dwmri_tensor_fa.nii.gz \
    --md_niigz /INPUTS/dwmri_tensor_md.nii.gz \
    --rd_niigz /INPUTS/dwmri_tensor_rd.nii.gz \
    --ad_niigz /INPUTS/dwmri_tensor_ad.nii.gz \
    --md_threshold 0.0003 \
    --label_info "PROJECT SUBJECT SESSION" \
    --out_dir /OUTPUTS
