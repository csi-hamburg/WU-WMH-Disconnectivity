#!/bin/bash

## crop WMH masks from MEvis to standard MNI space
## binarise masks


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

OUTDIR=$BASEDIR/derivatives/WMH_MNI

subs=$BASEDIR/input/WMH/masksBMF/sub-*

rm $OUTDIR/WMHvol.csv


for f in $subs; do
	ff=$OUTDIR/$(basename $f .nii.gz)_cropped.nii.gz
	[[ ! -f $ff ]] && fslroi $f $ff 5 182 6 218 2 182
	fff=$OUTDIR/$(basename $f .nii.gz)_bin.nii.gz
        [[ ! -f $fff ]] && fslmaths $ff -thr .5 -bin $fff
	
	subfn=$(basename $f)
	subID=${subfn/#sub-/}
	subID=${subID/%-v00*/}
	WMHvol=$(fslstats $fff -V | awk '{print $1}')
	echo "$subID $WMHvol" >> $OUTDIR/WMHvol.csv
done

heatmap=$OUTDIR/sumWMH.nii.gz
if [[ ! -f $heatmap ]]; then 
	fslmaths $BASEDIR/input/MNI152_T1_1mm_brain.nii.gz -mul 0 $heatmap 
	masks=$OUTDIR/sub-*_bin.nii.gz
	for f in $masks; do
		fslmaths $f -add $heatmap $heatmap
	done
fi

