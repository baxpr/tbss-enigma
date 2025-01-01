#!/usr/bin/env bash

echo Making PDF

# Work in output directory
cd ${out_dir}

# Timestamp
thedate=$(date)


# Subject FA and template FA to check registration
# Template FA > 0.2 (red) overlaid on subject FA
#
# Could add mask but it's visually confusing:
#           template_mask.nii.gz --overlayType mask -o -w 2 -mc 1 0 0

# Sagittal
c=0
for slice in -45 -25 0 25 45; do
    ((c++))
    fsleyes render -of sag_${c}.png \
        --scene ortho --worldLoc ${slice} 0 0 \
        --displaySpace world --size 600 600 \
        --hideCursor --hideLabels --hidey --hidez \
        fa_regWarped.nii.gz --displayRange 0 0.8 \
        template_FA.nii.gz --displayRange 2000 8000 --cmap red --alpha 50
    fsleyes render -of skelsag_${c}.png \
        --scene ortho --worldLoc ${slice} 0 0 \
        --displaySpace world --size 600 600 \
        --hideCursor --hideLabels --hidey --hidez \
        fa_regWarped.nii.gz --displayRange 0 0.8 \
        template_skeleton_mask.nii.gz --cmap red
done

# Coronal
c=0
for slice in -60 -40 -10 20 40; do
    ((c++))
    fsleyes render -of cor_${c}.png \
        --scene ortho --worldLoc 0 ${slice} 0 \
        --displaySpace world --size 600 600 \
        --hideCursor --hideLabels --hidex --hidez \
        fa_regWarped.nii.gz --displayRange 0 0.8 \
        template_FA.nii.gz --displayRange 2000 8000 --cmap red --alpha 50
    fsleyes render -of skelcor_${c}.png \
        --scene ortho --worldLoc 0 ${slice} 0 \
        --displaySpace world --size 600 600 \
        --hideCursor --hideLabels --hidex --hidez \
        fa_regWarped.nii.gz --displayRange 0 0.8 \
        template_skeleton_mask.nii.gz --cmap red
done

# Axial
c=0
for slice in -30 -10 10 25 50; do
    ((c++))
    fsleyes render -of axi_${c}.png \
        --scene ortho --worldLoc 0 0 ${slice} \
        --displaySpace world --size 600 600 \
        --hideCursor --hideLabels --hidex --hidey \
        fa_regWarped.nii.gz --displayRange 0 0.8 \
        template_FA.nii.gz --displayRange 2000 8000 --cmap red --alpha 50
    fsleyes render -of skelaxi_${c}.png \
        --scene ortho --worldLoc 0 0 ${slice} \
        --displaySpace world --size 600 600 \
        --hideCursor --hideLabels --hidex --hidey \
        fa_regWarped.nii.gz --displayRange 0 0.8 \
        template_skeleton_mask.nii.gz --cmap red
done


montage \
    -mode concatenate ???_1.png ???_2.png ???_3.png ???_4.png ???_5.png \
    -tile 3x -quality 100 -background black -gravity center \
    -border 0 -bordercolor black reg.png

montage \
    -mode concatenate skel???_1.png skel???_2.png skel???_3.png skel???_4.png skel???_5.png \
    -tile 3x -quality 100 -background black -gravity center \
    -border 0 -bordercolor black skel.png

convert -size 2600x3365 xc:white \
    -gravity center \( reg.png -resize 2400x2800 \) -composite \
    -gravity North -pointsize 40 -annotate +0+100 \
        "${label_info} Template FA (red) over subj FA" \
    -gravity SouthEast -pointsize 40 -annotate +100+100 "${thedate}" \
    page_reg.png

convert -size 2600x3365 xc:white \
    -gravity center \( skel.png -resize 2400x2800 \) -composite \
    -gravity North -pointsize 40 -annotate +0+100 \
        "${label_info} Template skeleton (red) over subj FA" \
    -gravity SouthEast -pointsize 40 -annotate +100+100 "${thedate}" \
    page_skel.png

convert page_reg.png page_skel.png tbss.pdf

