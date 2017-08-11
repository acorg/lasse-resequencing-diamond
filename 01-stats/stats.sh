#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

task=$1
fastq=$task
base=$(basename $fastq | sed -e 's/\.trim\.fastq\.gz//')
log=$logDir/$base.log
countOut=$statsDir/$base.count
MD5Out=$statsDir/$base.md5

if [ ! -f $fastq ]
then
    echo "  FASTQ file '$fastq' does not exist." >> $log
    exit 1
fi

function stats()
{
    # Count reads.
    echo "$fastq $(zcat $fastq | egrep '^\+$' | wc -l | awk '{print $1}')" > $countOut

    md5sum $fastq > $MD5Out
}

echo "01-stats on task $task started at `date`" >> $log
echo "  FASTQ is $fastq" >> $log

if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Stats is being skipped on this run." >> $log
    elif [ -f $countOut -a -f $MD5Out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output files $countOut and $MD5Out exist, but --force was used. Overwriting." >> $log
            stats
        else
            echo "  Will not overwrite pre-existing output files $countOut and $MD5Out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output files $countOut and $MD5Out do not both not exist. Collecting stats." >> $log
        stats
    fi
fi

echo "01-stats on task $task stopped at `date`" >> $log
echo >> $log
