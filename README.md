# ENIGMA TBSS protocol

TBSS following the ENIGMA protocol (https://enigma.ini.usc.edu/protocols/dti-protocols/).


## Preprocessing

Diffusion images are assumed already preprocessed to produce FA and MD images. A typical
preprocessing pipeline would be [PreQual](https://github.com/MASILab/PreQual). 

The provided MD image is thresholded at the `md_threshold` value to produce a tight brain mask, 
which is then applied to the FA image and also used in the registration.


## ENIGMA-DTI Skeletonization

The outline of the ENIGMA protocol is followed (`ENIGMA_TBSS_protocol_USC.pdf`). The
numbered steps of the protocol are handled as follows:

(1, template files) The default ENIGMA template FA image, tract skeleton, and skeleton distance image are used.
These are found in the `enigma` directory in this repository, but the original source was 
http://enigma.ini.usc.edu/wp-content/uploads/2013/02/enigmaDTI.zip (downloaded Dec 2024).

(2, file handling only)

(3, registration to template) The single subject FA image is registered to the FA template
using ANTS, specifically `antsRegistrationSyN.sh`. 
[Source code](https://github.com/ANTsX/ANTs/), [Documentation](http://stnava.github.io/ANTs/).
Relevent references for this script include:
   * http://www.ncbi.nlm.nih.gov/pubmed/20851191
   * http://www.frontiersin.org/Journal/10.3389/fninf.2013.00039/abstract
For QC, a PDF is produced to show the quality of registration between subject
and template.