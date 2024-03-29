#!/bin/bash

## Build QDEC table


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

OUTDIR=$BASEDIR/derivatives/qdec
mkdir -p $OUTDIR


cat $BASEDIR/derivatives/GLM/XX.csv | awk '{print $1,0,$6}' > lh.dat
cat $BASEDIR/derivatives/GLM/XX.csv | awk '{print $1,1,$6}' > rh.dat
echo "fsid hemi mRS" > header.dat
cat header.dat lh.dat rh.dat > $OUTDIR/qdec.table.dat
rm lh.dat rh.dat header.dat

echo "fsaverage fsaverage" > subjlistfile.txt
mris_preproc --is $BASEDIR/derivatives/NeMoMaps?surf/NeMo_5mm_lh.mgh --is $BASEDIR/derivatives/NeMoMaps_surf/NeMo_5mm_rh_on_lh.mgh --f subjlistfile.txt --hemi lh --target fsaverage --out $OUTDIR/NeMo_rh_on_lh.mgh
rm subjlistfile.txt
