##!/bin/bash

## Remove subcortical structures from NeMo maps


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

subs=$BASEDIR/derivatives/archives/*/*res1mm_mean.nii.gz


mkdir -p $BASEDIR/derivatives/NeMoMaps

for f in $subs; do
		ff=$BASEDIR/derivatives/NeMoMaps/$(basename $f .nii.gz)_woSC.nii.gz

		[[ ! -f $ff ]] && fslmaths $FSLDIR/data/standard/MNI152_T1_1mm_subbr_mask.nii.gz -binv -mul $f $ff

	done
