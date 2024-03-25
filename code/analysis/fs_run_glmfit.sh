#!/bin/bash

## run mri_glmfit to associate voxelwise NeMo with mRS outcome


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..


# rm -rf $BASEDIR/derivatives/glmfit.*
#GLMDIR=$(mktemp -d -p $BASEDIR/derivatives  -t glmfit.XXXXXX)
# GLMDIR=$(ls -d $BASEDIR/derivatives/glmfit.G6*)

hemi=$1
OUTDIR=$BASEDIR/derivatives/GLM/${hemi}

## NeMo ~ mRS
mkdir -p $OUTDIR/mRS

cat $BASEDIR/derivatives/GLM/XX.csv | awk -F ' ' '{print 1,$2,$3,$4,$7,$6}' > $OUTDIR/mRS/X.csv

matlab -nodisplay -nodesktop -r "X=dlmread('$OUTDIR/mRS/X.csv', ' '); save('$OUTDIR/mRS/X.mat','X','-v4'); quit"

echo -e "0 0 0 0 0 1" > $OUTDIR/mRS/mRS_pos.mat

mri_glmfit --glmdir $OUTDIR/mRS --y $BASEDIR/derivatives/NeMoMaps_surf/NeMo_${hemi}.mgh --X $OUTDIR/mRS/X.mat --C $OUTDIR/mRS/mRS_pos.mat --surface fsaverage ${hemi}  --no-prune


## NeMo ~ mRS*Tx
mkdir -p $OUTDIR/mRSxTx

cat $BASEDIR/derivatives/GLM/XX.csv | awk -F ' ' '{print 1,$2,$3,$4,$7,$5,$6,$5*$6}' > $OUTDIR/mRSxTx/X.csv

mean=$(cat $GLMDIR/mRSxTx/X.csv | awk '{ sum += $3 } END { if (NR > 0) print sum / NR }')

matlab -nodisplay -nodesktop -r "X=dlmread('$OUTDIR/mRSxTx/X.csv', ' '); save('$OUTDIR/mRSxTx/X.mat','X','-v4'); quit"

echo -e "0 0 0 0 0 0 0 1" > $OUTDIR/mRSxTx/Ix_pos.mat
echo -e "0 0 0 0 0 0 0 -1" > $OUTDIR/mRSxTx/Ix_neg.mat

mri_glmfit --glmdir $OUTDIR/mRSxTx --y $BASEDIR/derivatives/NeMoMaps_surf/NeMo_${hemi}.mgh --X $OUTDIR/mRSxTx/X.mat --C $OUTDIR/mRSxTx/Ix_pos.mat --C $OUTDIR/mRSxTx/Ix_neg.mat --surface fsaverage ${hemi} --no-prune

