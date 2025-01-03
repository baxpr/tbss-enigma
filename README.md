# ENIGMA TBSS protocol

TBSS following the ENIGMA protocol (https://enigma.ini.usc.edu/protocols/dti-protocols/).

**INPUTS**

    Subject FA image
    Subject MD image

**OUTPUTS**

    fa.nii.gz                          Masked input images  (subject native space)
    md.nii.gz
    
    mask.nii.gz                        Brain mask (subject native space)
    
    fa_reg0GenericAffine.mat           ANTS transform from native to template space
    fa_reg1Warp.nii.gz
    
    tbss.pdf                           Registration QC PDF
    
    fa_regWarped.nii.gz                Subject FA, MD images (template space)
    md_regWarped.nii.gz
    
    fa_regWarped_skeletonised.nii.gz   Skeletonized subject FA, MD images
    md_regWarped_skeletonised.nii.gz        (template space)
    
    extracted_roi_means.csv            FA, MD values in JHU ROIs


## Preprocessing

Diffusion images are assumed already preprocessed to produce FA and MD images. A typical
preprocessing pipeline would be [PreQual](https://github.com/MASILab/PreQual). 

The provided MD image is thresholded at the `md_threshold` value to produce a tight brain mask, 
which is then applied to the FA image and also used in the registration.


## ENIGMA-DTI Skeletonization

The outline of the ENIGMA protocol is followed (`enigma/ENIGMA_TBSS_protocol_USC.pdf`). The
numbered steps of the protocol are handled as follows:

(1, template files) The default ENIGMA template FA image, tract skeleton, and skeleton 
distance image are used. These are found in the `enigma` directory in this repository, but 
the original source was http://enigma.ini.usc.edu/wp-content/uploads/2013/02/enigmaDTI.zip 
(downloaded Dec 2024).

(2, file handling only)

(3, FA image erosion) This step is skipped as the registration algorithm does not need it.

(4, registration to template) The single subject FA image is registered to the FA template
using ANTS, specifically `antsRegistrationSyN.sh`. 
[Source code](https://github.com/ANTsX/ANTs/), [Documentation](http://stnava.github.io/ANTs/).
Relevant references for this script include:
   * http://www.ncbi.nlm.nih.gov/pubmed/20851191
   * http://www.frontiersin.org/Journal/10.3389/fninf.2013.00039/abstract
   
The registration is also applied to the subject MD image. For QC, a PDF is produced to show 
the quality of registration between subject and template.

(5, template mask creation) Skipped. The default ENIGMA mask is used.

(6, distance map creation) Skipped. The default ENIGMA skeleton and distance image are used.

(7, parallelization) Not used, as only a single subject is processed.

(8, Skeletonize subject images) FSL's `tbss_skeleton` function is used to project the 
registered subject FA and MD images onto the template skeleton.


## ROI signal extraction

The ENIGMA protocol is described in `enigma/ENIGMA_ROI_protocol_USC.pdf`, and
the accompanying files are found in the `enigma/ROIextraction_info` directory of
this repository (downloaded Dec 2024). But, the described code and processing steps 
are not used. The underlying procedure however is followed - Subject FA within the 
skeleton is averaged within each ROI of the 
`enigma/ROIextraction_info/JHU-WhiteMatter-labels-1mm.nii.gz`
image, ignoring zero-valued (non-skeleton) voxels. The ROIs are listed in the file
`enigma/ROIextraction_info/ENIGMA_look_up_table.txt`.

