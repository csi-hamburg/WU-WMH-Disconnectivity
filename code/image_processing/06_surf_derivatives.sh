#!/bin/bash

## Crete derivatives of surface files


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

FWHM=5

OUTDIR=$BASEDIR/derivatives/NeMoMaps_surf_derivatives
mkdir -p $OUTDIR




for hemi in lh rh rh_on_lh; do
    # Smooth by $FWHM
    mris_fwhm --i $BASEDIR/derivatives/NeMoMaps_surf/NeMo_${hemi}.mgh --s fsaverage --hemi ${hemi/rh_on_/} --surf white --fwhm ${FWHM} --o $OUTDIR/NeMo_${FWHM}mm_${hemi}.mgh

    # Sqrt transformation to improve linearity between ChaCo and mRS
    #fscalc $OUTDIR/NeMo_${FWHM}mm_${hemi}.mgh sqrt --o $OUTDIR/NeMo_${FWHM}mm_sqrt_${hemi}.mgh
    matlab -nosplash -nodesktop -r "a = MRIread('$OUTDIR/NeMo_${FWHM}mm_${hemi}.mgh'); \
    a.vol = sqrt(a.vol); \
    MRIwrite(a, '$OUTDIR/NeMo_${FWHM}mm_sqrt_${hemi}.mgh'); \
    quit"


    # Resample to fsaverage5
    mri_surf2surf --srcsubject fsaverage --trgsubject fsaverage5 --hemi ${hemi/rh_on_/} --sval $OUTDIR/NeMo_${FWHM}mm_sqrt_${hemi}.mgh --tval $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_${hemi}.mgh    
done

# Merge lh and rh

echo "fsaverage5 fsaverage5" > 2xfsaverage5.txt
mris_preproc --is  $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_lh.mgh --is $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_rh_on_lh.mgh --f 2xfsaverage5.txt --hemi lh --target fsaverage5 --out $OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_lh+rh_on_lh.mgh
rm 2xfsaverage5.txt

# reorder by subject

matlab -nosplash -nodesktop -r "a = MRIread('$OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_lh+rh_on_lh.mgh'); \
n = size(a.vol,4)/2; \
a.vol = a.vol(:,:,:,[kron(eye(n),[1;0]), kron(eye(n),[0;1])]*(1:2*n)'); \
MRIwrite(a, '$OUTDIR/NeMo_${FWHM}mm_sqrt_fs5_lh+rh_on_lh_by_subj.mgh'); \
quit"