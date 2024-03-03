#!/bin/bash

## transform WMH masks from native FLAIR to MNI space


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

subs=($(ls -d $BASE_DIR/input/WMH/WAKE_UP/sub-*/))

subs=$BASEDIR/input/WMH/WAKE_UP/sub-*
echo $subs

#postfix=("${subs[@]//*sub-}")   # array
#IDs="${postfix[@]%%-v00\/}"     # not an array

for sub in $subs; do
    flirt   -in $sub/$(basename $sub)_lesion_mask_ero13_mincluster_20_bin_done.nii.gz  \
            -ref $BASEDIR/input/MNI152_T1_1mm_brain.nii.gz \
            -init $sub/$(basename $sub)_FLAIR_to_MNI_12DOF.mat \
            -applyxfm \
            -out $BASEDIR/derivatives/WMH_MNI/$(basename $sub)_WMH_MNI.nii.gz

            ## threshold & binarise
done

## aggregate for visualisation