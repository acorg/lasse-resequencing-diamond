# IMPORTANT: All paths in this file are relative to the scripts in
# 00-start, etc. This file is sourced by those scripts.

rootDir=../../..
logDir=../logs
doneFile=../slurm-pipeline.done
runningFile=../slurm-pipeline.running
errorFile=../slurm-pipeline.error
sampleLogFile=$logDir/sample.log
statsDir=$rootDir/stats

# A simple way to set defaults for our SP_* variables, without causing
# problems by using test when set -e is active (causing scripts to exit
# with status 1 and no explanation).
echo ${SP_SIMULATE:=0} ${SP_SKIP:=0} ${SP_FORCE:=0} >/dev/null

function sampleName()
{
    echo $(/bin/pwd | tr / ' ' | perl -ane 'print $F[-4], "\n"' | sed -e 's/Project_//')
}
