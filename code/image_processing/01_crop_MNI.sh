#!/bin/bash

## crop WMH masks from Mevis to standard MNI space
## binarise masks
## compute and save WMH volume

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

OUTDIR=$BASEDIR/derivatives/WMH_MNI
mkdir -p $OUTDIR

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

	fff_lh=$OUTDIR/$(basename $fff .nii.gz)_lh.nii.gz
	[[ ! -f $fff_lh ]] && fslroi $fff $fff_lh 1 91 1 218 1 182
	WMHvol_lh=$(fslstats $fff_lh -V | awk '{print $1}')
	fff_rh=$OUTDIR/$(basename $fff .nii.gz)_rh.nii.gz
	[[ ! -f $fff_rh ]] && fslroi $fff $fff_rh 92 91 1 218 1 182
	WMHvol_rh=$(fslstats $fff_rh -V | awk '{print $1}')


	echo "$subID $WMHvol $WMHvol_lh $WMHvol_rh" >> $OUTDIR/WMHvol.csv
done

heatmap=$OUTDIR/sumWMH.nii.gz
if [[ ! -f $heatmap ]]; then 
	fslmaths $BASEDIR/input/MNI152_T1_1mm_brain.nii.gz -mul 0 $heatmap 
	masks=$OUTDIR/sub-*_bin.nii.gz
	for f in $masks; do
		fslmaths $f -add $heatmap $heatmap
	done
fi

