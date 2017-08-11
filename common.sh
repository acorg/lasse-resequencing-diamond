# IMPORTANT: All paths in this file are relative to the scripts in
# 00-start, etc. This file is sourced by those scripts.

rootDir=../../..
logDir=../logs
doneFile=../slurm-pipeline.done
runningFile=../slurm-pipeline.running
errorFile=../slurm-pipeline.error
sampleLogFile=$logDir/sample.log
statsDir=$rootDir/stats

test -z "$SP_SIMULATE" && export SP_SIMULATE=0
test -z "$SP_SKIP" && export SP_SKIP=0
test -z "$SP_FORCE" && export SP_FORCE=0

function sampleName()
{
    echo $(/bin/pwd | tr / ' ' | perl -ane 'print $F[-4], "\n"' | sed -e 's/Project_//')
}
