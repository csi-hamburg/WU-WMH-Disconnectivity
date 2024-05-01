#!/bin/bash

## Crete derivatives of surface files


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

FWHM=5

OUTDIR=$BASEDIR/derivatives/NeMoMaps_surf_derivatives
mkdir -p $OUTDIR

# Smmoth by $FWHM

mris_fwhm --i $BASEDIR/derivatives/NeMoMaps_surf/NeMo_lh.mgh --s fsaverage --hemi lh --surf white --fwhm ${FWHM} --o $OUTDIR/NeMo_${FWHM}mm_lh.mgh
mris_fwhm --i $BASEDIR/derivatives/NeMoMaps_surf/NeMo_rh.mgh --s fsaverage --hemi rh --surf white --fwhm ${FWHM} --o $OUTDIR/NeMo_${FWHM}mm_rh.mgh
mris_fwhm --i $BASEDIR/derivatives/NeMoMaps_surf/NeMo_rh_on_lh.mgh --s fsaverage --hemi lh --surf white --fwhm ${FWHM} --o $OUTDIR/NeMo_${FWHM}mm_rh_on_lh.mgh

# Sqrt transformation to improve linearity between ChaCo and mRS

fscalc $BASEDIR/derivatives/NeMoMaps_surf/NeMo_${FWHM}mm_lh.mgh sqrt --o $OUTDIR/NeMo_${FWHM}mm_sqrt_lh.mgh
fscalc $BASEDIR/derivatives/NeMoMaps_surf/NeMo_${FWHM}mm_rh.mgh sqrt --o $OUTDIR/NeMo_${FWHM}mm_sqrt_rh.mgh
fscalc $BASEDIR/derivatives/NeMoMaps_surf/NeMo_${FWHM}mm_rh_on_lh.mgh sqrt --o $OUTDIR/NeMo_${FWHM}mm_sqrt_rh_on_lh.mgh

# Rsample to fsaverage5

mri_surf2surf --srcsubject fsaverage --trgsubject fsaverage5 --hemi lh --sval $OUTDIR/NeMo_${FWHM}mm_sqrt_lh.mgh --tval $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_lh.mgh
mri_surf2surf --srcsubject fsaverage --trgsubject fsaverage5 --hemi rh --sval $OUTDIR/NeMo_${FWHM}mm_sqrt_rh.mgh --tval $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_rh.mgh
mri_surf2surf --srcsubject fsaverage --trgsubject fsaverage5 --hemi lh --sval $OUTDIR/NeMo_${FWHM}mm_sqrt_rh_on_lh.mgh --tval $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_rh_on_lh.mgh

# Merge lh and rh

echo "fsaverage fsaverage" > 2xfsaverage.txt
mris_preproc --is  $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_lh.mgh --is $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_rh_on_lh.mgh --f 2xfsaverage.txt --hemi lh --target fsaverage --out $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_lh+rh_on_lh.mgh
rm 2xfsaverage.txt


