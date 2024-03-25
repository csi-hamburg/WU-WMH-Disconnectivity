##!/bin/bash

## Project WMH disconnectivity to FS surface


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

FWHM=5

OUTDIR=$BASEDIR/derivatives/NeMoMaps_surf

subs=($BASEDIR/derivatives/NeMoMaps/*_woSC.nii.gz)
printf 'fsaverage%.0s ' $(seq 1 ${#subs[@]}) | awk '{$1=$1};1' > $OUTDIR/subjlistfile.txt


for hemi in lh rh; do
	for f in ${subs[*]}; do
		ff=$OUTDIR/$(basename $f .nii.gz)_${hemi}.mgh
		[[ ! -f $ff ]] && mri_vol2surf \
			--mov $f \
			--mni152reg \
			--out $ff \
			--hemi $hemi
	done
	
	subsFS=($OUTDIR/*_woSC_${hemi}.mgh)

	
	mris_preproc ${subsFS[*]/#/'--is '} --f $OUTDIR/subjlistfile.txt --hemi ${hemi} --target fsaverage --out $OUTDIR/NeMo_${hemi}.mgh

	mris_fwhm --i $OUTDIR/NeMo_${hemi}.mgh --s fsaverage --hemi ${hemi} --surf white --fwhm ${FWHM} --o $OUTDIR/NeMo_${FWHM}mm_${hemi}.mgh
	
done


