#!/bin/bash

## Build design template for mri_glmfit


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

OUTDIR=$BASEDIR/derivatives/GLM
mkdir -p $OUTDIR

# filter by subjects
subs=($BASEDIR/derivatives/NeMoMaps/*_woSC.nii.gz)

subsfn=($(basename -a ${subs[*]}))
subsID=(${subsfn[@]/#sub-/})
subsID=(${subsID[@]/%-v00*/})

(IFS='|'; cat $BASEDIR/derivatives/clinical.csv | grep -E "^${subsID[*]}") | awk -F ' ' '{print $0}' > $OUTDIR/X.csv

# Recode rtPA=1, Placebo=0
sed -i 's/rtPA/1/g;s/Placebo/0/g' $OUTDIR/X.csv

# mean impute mRS
export LC_ALL=C; mean=$(cat $OUTDIR/X.csv | awk '{ sum += $6 } END { if (NR > 0) print sum / NR }')
sed -i "s/NA/$mean/g" $OUTDIR/X.csv

# combine with WMH vol data and check that SUBJID agree
paste -d ' ' $OUTDIR/X.csv $BASEDIR/derivatives/WMH_MNI/WMHvol.csv | awk '$1==$7 {print $1, $2, $3, $4, $5, $6, $8, $9, $10}' > $OUTDIR/X_full.csv

