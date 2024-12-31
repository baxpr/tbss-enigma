FA template files in this directory downloaded from
https://enigma.ini.usc.edu/protocols/dti-protocols/
and links referred to in that documentation.

The originally supplied images are described below but these are now named NNN.nii.gz.orig and
the NNN.nii.gz have geometry adjusted by the `fix_geometry.sh` script.

FA image geometry:

    qto_xyz:1	-1.000000 0.000000 -0.000000 90.000000 
    qto_xyz:2	0.000000 1.000000 -0.000000 -126.000000 
    qto_xyz:3	0.000000 0.000000 1.000000 -72.000000 
    qto_xyz:4	0.000000 0.000000 0.000000 1.000000

Corresponding files:

    ENIGMA_DTI_FA                      FA image, value range (0,8924)
    ENIGMA_DTI_FA_skeleton             FA on skeleton, values (0,8950)
    ENIGMA_DTI_FA_skeleton_mask        Skeleton mask, values 0/1


Mask image geometry (displaced from FA image; seems erroneous):

    qto_xyz:1	1.000000 0.000000 0.000000 0.000000 
    qto_xyz:2	0.000000 1.000000 0.000000 0.000000 
    qto_xyz:3	0.000000 0.000000 1.000000 0.000000 
    qto_xyz:4	0.000000 0.000000 0.000000 1.000000

Corresponding files:

    ENIGMA_DTI_FA_mask                 Brain mask
    ENIGMA_DTI_FA_skeleton_mask_dst    Distance from skeleton, values (0,14.3)
