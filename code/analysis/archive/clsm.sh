#!/bin/bash

## Prepare and run LSM via clsm


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/../..


subs=($BASEDIR/derivatives/WMH_MNI_cropped/*_cropped.nii.gz)

subsfn=($(basename -a ${subs[*]}))
subsID=(${subsfn[@]/#sub-/})
subsID=(${subsID[@]/%-v00*/})

echo ${subsID[@]}

printf "%s\n" "$(basename -a ${subs[@]})" > filenames.txt


(IFS='|'; cat $BASEDIR/derivatives/clinical.csv | grep -E "^${subsID[*]}") | awk -F ' ' -v OFS='\t' '{print $6}' > preDESIGN.txt

echo -e "Filename\tmRS" > DESIGN.txt
paste filenames.txt preDESIGN.txt >> DESIGN.txt


matlab -nosplash -nodesktop "run_clsm"

