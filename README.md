# WU-WMH-Disconnectivity
Analysis of WMH disconnectivity in the WAKE-UP trial

## Software prereqs
Freesurfer (vX), FSL (vX, incl. PALM), Matlab (v2024b, incl brainstat)

## Imaging preprocessing pipeline 
WMH segmentation according to Frey et al.

Binarisation (thr 0.5) and cropping to 182x182x219 MNI152 space

Network mapping using NeMo v2.1.18

Removal of subcortical structures, projecting to fsaverage surface, smoothing (FWHM 5mm)

## Statistical analysis
Fitting of vertexwise linear models for left and right hemisphere separately
+ sqrt(ChaCo) ~ mRS
+ sqrt(ChaCo) ~ mRS + covs
+ sqrt(ChaCo) ~ mRS + hemi + (1|subj)
+ sqrt(ChaCo) ~ mRS + hemi + covs + (1|subj),

and inter-/cross-hemispheric
+ sqrt(ChaCo) ~ mRS*hemi + (1|subj)
+ sqrt(ChaCo) ~ mRS*hemi + covs + (1|subj)

Covariates (covs) include _age_, _sex_, and _log(WMHvol)_. Baseline _NIHSS score_, _infarct lesion volume_, and _intravenous thrombolysis_ are not considered (-> causal model justification).

Models are fitted with both PALM and brainstat, error control uses TFCE, FDR and RFT.
