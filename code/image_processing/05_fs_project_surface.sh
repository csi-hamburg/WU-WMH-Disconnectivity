#!/bin/bash

## Project WMH disconnectivity to FS surface
## Do cross-hemispheric registration rh -> lh
## Smooth using FWHM 5mm


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

FWHM=5

OUTDIR=$BASEDIR/derivatives/NeMoMaps_surf
mkdir -p $OUTDIR

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
		fff=$OUTDIR/$(basename $f .nii.gz)_rh_on_lh.mgh
		[[ ! -f $fff ]] && [[ "$hemi" == rh ]] && mris_apply_reg \
			--src $ff \
			--trg $fff \
			--streg $FREESURFER/subjects/fsaverage/xhemi/surf/lh.fsaverage_sym.sphere.reg $FREESURFER/subjects/fsaverage/surf/lh.fsaverage_sym.sphere.reg


	done
	
	subsFS=($OUTDIR/*_woSC_${hemi}.mgh)

		
	f=$OUTDIR/NeMo_${hemi}.mgh
	[[ ! -f $f ]] && mris_preproc ${subsFS[*]/#/'--is '} --f $OUTDIR/subjlistfile.txt --hemi ${hemi} --target fsaverage --out $f
	ff=$OUTDIR/NeMo_${FWHM}mm_${hemi}.mgh
	[[ ! -f $ff ]] && mris_fwhm --i $f --s fsaverage --hemi ${hemi} --surf white --fwhm ${FWHM} --o $ff	
done

subsFS=($OUTDIR/*_woSC_rh_on_lh.mgh)

f=$OUTDIR/NeMo_rh_on_lh.mgh
[[ ! -f $f ]] && mris_preproc ${subsFS[*]/#/'--is '} --f $OUTDIR/subjlistfile.txt --hemi lh --target fsaverage --out $f
ff=$OUTDIR/NeMo_${FWHM}mm_rh_on_lh.mgh
[[ ! -f $ff ]] && mris_fwhm --i $f --s fsaverage --hemi lh --surf white --fwhm ${FWHM} --o $ff

#echo "fsaverage fsaverage" > 2xfsaverage.txt
#mris_preproc --is $OUTDIR/NeMo_${FWHM}mm_lh.mgh --is $OUTDIR/NeMo_${FWHM}mm_rh_on_lh.mgh --f 2xfsaverage.txt --hemi lh --target fsaverage --out $OUTDIR/NeMo_${FWHM}mm_lh+rh_on_lh.mgh
#rm 2xfsaverage.txt
