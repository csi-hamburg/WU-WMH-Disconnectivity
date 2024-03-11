#!/bin/bash

## Project WMH disconnectivity to FS surface


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

subs=$BASEDIR/derivatives/archives/*/*res1mm_mean.nii.gz

for f in $subs; do
	for hemi in lh rh; do
		mri_vol2surf \
			--mov $f \
			--mni152reg \
			--out $BASEDIR/derivatives/freesurfer/$(basename $f .nii.gz)_${hemi}.mgh \
			--hemi $hemi
		done
	done
