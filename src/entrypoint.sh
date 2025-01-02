#!/usr/bin/env bash
#
# Entrypoint for ENIGMA TBSS pipeline

# Defaults
export fa_niigz=/INPUTS/fa.nii.gz
export md_niigz=/INPUTS/md.nii.gz
export enigma_dir=/opt/tbss-enigma/enigma
export md_threshold=0.0003
export out_dir=/OUTPUTS
export label_info=

# Parse input options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --fa_niigz)      export fa_niigz="$2";      shift; shift ;;
        --md_niigz)      export md_niigz="$2";      shift; shift ;;
        --out_dir)       export out_dir="$2";       shift; shift ;;
        --enigma_dir)    export enigma_dir="$2";    shift; shift ;;
        --md_threshold)  export md_threshold="$2";  shift; shift ;;
        --label_info)    export label_info="$2";    shift; shift ;;
        *) echo "Input ${1} not recognized"; shift ;;
    esac
done

# Run pipeline
enigma_tbss_pipeline.sh

# Generate QC PDF
xwrapper.sh make_pdf.sh
