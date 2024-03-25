#!/bin/bash

## run fspalm on output from mri_glmfit


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

hemi=$1
OUTDIR=$BASEDIR/derivatives/GLM/${hemi}

## NeMo ~ mRS
fspalm --glmdir $OUTDIR/mRS --cft 1.3 --onetail --name palm --iters 1000 --cwp .1


## NeMo ~ mRS*Tx
fspalm --glmdir $OUTDIR/mRSxTx --cft 1.3 --onetail --name palm --iters 1000 --cwp .1

