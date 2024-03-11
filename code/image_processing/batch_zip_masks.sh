#!/bin/bash

## compress binarised WMH masks into zip files, containing 10 masks each

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..

filenames=( $BASEDIR/derivatives/WMH_MNI_cropped/*_bin.nii.gz )
for ((index=1; index <= $(( (${#filenames[@]} / 10) + 1)); index++)); do
  start=$(( (index-1) * 10 ))
  zip $BASEDIR/derivatives/WMH_MNI_cropped/archives/archive"$(printf "%02d" $index)".zip "${filenames[@]:start:9}"
done
