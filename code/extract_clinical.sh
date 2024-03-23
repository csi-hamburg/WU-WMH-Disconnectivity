#!/bin/bash

## extract and save relevant clinial data from master file


DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASEDIR=$DIR/..

#
V0=$BASEDIR/derivatives/clinical_V0.csv
cat $BASEDIR/input/wakeup_master_csv_CORRECTED.csv  | awk -F ';' 'NR==1 {
									for (i=1; i<=NF; i++) {
        									f[$i] = i
    									}
								}
								$(f["VISITNUM"])=="Visit 0" { print $1, $(f["AGE"]), $(f["SEX"]), $(f["NIHSSSCORE"]), $(f["codetrt"]) }' > $V0

V5=$BASEDIR/derivatives/clinical_V5.csv
cat $BASEDIR/input/wakeup_master_csv_CORRECTED.csv  | awk -F ';' 'NR==1 {
									for (i=1; i<=NF; i++) {
        									f[$i] = i
    									}
								}
								$(f["VISITNUM"])=="Visit 5" { print $1, $(f["MRSSCORE"]) }' > $V5

# make sure SUBJID agree across time points V0 and V5
paste -d ' ' $V0 $V5 | awk '$1==$6 {print $1, $2, $3, $4, $5, $7}' > $BASEDIR/derivatives/clinical.csv

