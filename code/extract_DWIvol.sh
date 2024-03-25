#!/bin/bash

## extract and save DWI lesion volume data from master file


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/..

cat $BASEDIR/input/WU_lesiondata.csv  | awk -F ',' 'NR>1 {print $1,$5}' > $BASEDIR/derivatives/DWIvol.csv
