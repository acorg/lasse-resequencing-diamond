#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

log=$sampleLogFile

echo "SLURM pipeline finished at `date`" >> $log

touch $doneFile
rm -f $runningFile
