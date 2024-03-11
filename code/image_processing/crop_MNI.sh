#!/bin/bash

## crop WMH masks from MEvis to standard MNI space
## binarise masks


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..


subs=$BASEDIR/input/WMH/masksBMF/sub-*
echo $subs

for f in $subs; do
	ff=$BASEDIR/derivatives/WMH_MNI_cropped/$(basename $f .nii.gz)_cropped.nii.gz
	[[ ! -f $ff ]] && fslroi $f $ff 5 182 6 218 2 182
	fff=$BASEDIR/derivatives/WMH_MNI_cropped/$(basename $f .nii.gz)_bin.nii.gz
        [[ ! -f $fff ]] && fslmaths $ff -thr .5 -bin $fff
done

heatmap=$BASEDIR/derivatives/WMH_MNI_cropped/sumWMH.nii.gz
fslmaths $BASEDIR/input/MNI152_T1_1mm_brain.nii.gz -mul 0 $heatmap 
masks=$BASEDIR/derivatives/WMH_MNI_cropped/sub-*_bin.nii.gz
for f in $masks; do
	fslmaths $f -add $heatmap $heatmap
done

## aggregate for visualisation
