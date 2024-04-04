#!/bin/bash

## run fspalm on output from mri_glmfit


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

hemi=$1
OUTDIR=$BASEDIR/derivatives/GLM/${hemi}

## NeMo ~ mRS
fspalm --glmdir $OUTDIR/mRS --cft 1 --onetail --name palm-1p0-0p1-1000 --iters 1000 --cwp .1


## NeMo ~ mRS*Tx
fspalm --glmdir $OUTDIR/mRSxTx --cft 1.3 --onetail --name palm-1p3-0p1-1000 --iters 1000 --cwp .1

