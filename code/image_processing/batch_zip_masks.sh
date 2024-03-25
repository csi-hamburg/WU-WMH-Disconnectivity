#!/bin/bash

## compress binarised WMH masks into zip files, containing 10 masks each

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

mkdir -p $BASEDIR/derivatives/WMH_MNI/archives

filenames=( $BASEDIR/derivatives/WMH_MNI/*_bin.nii.gz )
for ((index=1; index <= $(( (${#filenames[@]} / 10) + 1)); index++)); do
  start=$(( (index-1) * 10 ))
  zip $BASEDIR/derivatives/WMH_MNI/archives/archive"$(printf "%02d" $index)".zip "${filenames[@]:start:10}"
done
