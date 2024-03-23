#!/bin/bash

## Prepare and run mri_glmfit to associate voxelwise NeMo with treatment


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

subs=($BASEDIR/derivatives/freesurfer/*_lh.mgh)

echo ${#subs[@]}
echo ${subs[*]/#/'--is '}


subsfn=($(basename -a ${subs[*]}))
subsID=(${subsfn[@]/#sub-/})
subsID=(${subsID[@]/%-v00*/})

echo ${subsID[@]}

rm -rf $BASEDIR/derivatives/glmfit.*

GLMDIR=$(mktemp -d -p $BASEDIR/derivatives  -t glmfit.XXXXXX)
echo $GLMDIR

printf 'fsaverage%.0s ' $(seq 1 ${#subs[@]}) | awk '{$1=$1};1' > $GLMDIR/subjlistfile.txt

mris_preproc ${subs[*]/#/'--is '} --f $GLMDIR/subjlistfile.txt --hemi lh --target fsaverage --out $GLMDIR/subs.mgh

## NeMo ~ mRS
mkdir $GLMDIR/mRS

(IFS='|'; cat $BASEDIR/derivatives/clinical.csv | grep -E "^${subsID[*]}") | awk -F ' ' '{print 1,$6}' > $GLMDIR/mRS/X.csv

mean=$(cat $GLMDIR/mRS/X.csv | awk '{ sum += $2 } END { if (NR > 0) print sum / NR }')
sed -i "s/NA/$mean/g" $GLMDIR/mRS/X.csv


matlab -nodisplay -nodesktop -r "X=dlmread('$GLMDIR/mRS/X.csv', ' '); save('$GLMDIR/mRS/X.mat','X','-v4'); quit"

echo "0 1\n" > $GLMDIR/mRS/mRS_pos.mat
echo "0 -1\n" > $GLMDIR/mRS/mRS_neg.mat

mri_glmfit --glmdir $GLMDIR/mRS --y $GLMDIR/subs.mgh --X $GLMDIR/mRS/X.mat --C $GLMDIR/mRS/mRS_pos.mat --C $GLMDIR/mRS/mRS_neg.mat --surface fsaverage lh


## NeMo ~ mRS + Tx
mkdir $GLMDIR/mRS+Tx

(IFS='|'; cat $BASEDIR/derivatives/clinical.csv | grep -E "^${subsID[*]}") | sed 's/rtPA/1/g' | sed 's/Placebo/0/g' | awk -F ' ' '{print 1,$5,$6}' > $GLMDIR/mRS+Tx/X.csv

mean=$(cat $GLMDIR/mRS+Tx/X.csv | awk '{ sum += $3 } END { if (NR > 0) print sum / NR }')
sed -i "s/NA/$mean/g" $GLMDIR/mRS+Tx/X.csv

matlab -nodisplay -nodesktop -r "X=dlmread('$GLMDIR/mRS+Tx/X.csv', ' '); save('$GLMDIR/mRS+Tx/X.mat','X','-v4'); quit"

echo "0 0 1\n" > $GLMDIR/mRS+Tx/mRS_pos.mat
echo "0 0 -1\n" > $GLMDIR/mRS+Tx/mRS_neg.mat

mri_glmfit --glmdir $GLMDIR/mRS+Tx --y $GLMDIR/subs.mgh --X $GLMDIR/mRS+Tx/X.mat --C $GLMDIR/mRS+Tx/mRS_pos.mat --C $GLMDIR/mRS+Tx/mRS_neg.mat --surface fsaverage lh


## NeMo ~ mRS*Tx
mkdir $GLMDIR/mRSxTx

(IFS='|'; cat $BASEDIR/derivatives/clinical.csv | grep -E "^${subsID[*]}") | sed 's/rtPA/1/g' | sed 's/Placebo/0/g' | awk -F ' ' '{print 1,$5,$6,$5*$6}' > $GLMDIR/mRSxTx/X.csv

mean=$(cat $GLMDIR/mRSxTx/X.csv | awk '{ sum += $3 } END { if (NR > 0) print sum / NR }')
sed -i "s/NA/$mean/g" $GLMDIR/mRSxTx/X.csv



matlab -nodisplay -nodesktop -r "X=dlmread('$GLMDIR/mRSxTx/X.csv', ' '); save('$GLMDIR/mRSxTx/X.mat','X','-v4'); quit"

echo "0 0 0 1\n" > $GLMDIR/mRSxTx/Ix_pos.mat
echo "0 0 0 -1\n" > $GLMDIR/mRSxTx/Ix_neg.mat

mri_glmfit --glmdir $GLMDIR/mRSxTx --y $GLMDIR/subs.mgh --X $GLMDIR/mRSxTx/X.mat --C $GLMDIR/mRSxTx/Ix_pos.mat --C $GLMDIR/mRSxTx/Ix_neg.mat --surface fsaverage lh


