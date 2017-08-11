#!/bin/bash -e

. $HOME/.virtualenvs/35/bin/activate
. ../common.sh

# The log file is the top-level sample log file, seeing as this step is a
# 'collect' step that is only run once.
log=$sampleLogFile
out=summary-virus

echo "04-panel started at `date`" >> $log


# Find the sequence files that correspond to this sample.
tasks=$(find $rootDir -name '*.trim.fastq.gz')

if [ -z "$tasks" ]
then
    echo "  No FASTQ found for this sample." >> $log
    exit 1
fi

allJSON=
allFASTQ=
for task in $tasks
do
    echo "  Task (i.e., sequencing run) $task" >> $log
    base=$(basename $task | sed -e 's/\.trim\.fastq\.gz//')

    JSON=../03-diamond/$base.json.bz2
    test -f $JSON || {
        echo "JSON file $JSON does not exist." >> $log
        exit 1
    }

    FASTQ=../02-map/$base-unmapped.fastq.gz
    test -f $FASTQ || {
        echo "FASTQ file $FASTQ does not exist." >> $log
        exit 1
    }

    allJSON="$allJSON $JSON"
    allFASTQ="$allFASTQ $FASTQ"
done

dbFastaFile=$HOME/scratch/root/share/ncbi/viral-refseq/viral-protein-20161124/viral.protein.fasta

if [ ! -f $dbFastaFile ]
then
    echo "  DIAMOND database FASTA file $dbfile does not exist!" >> $log
    exit 1
fi

function skip()
{
    # We're being skipped. Make an empty output file, if one doesn't
    # already exist. There's nothing much else we can do and there's no
    # later steps to worry about.
    [ -f $out ] || touch $out
}

function panel()
{
    echo "  noninteractive-alignment-panel.py started at `date`" >> $log
    noninteractive-alignment-panel.py \
      --json $allJSON \
      --fastq $allFASTQ \
      --matcher diamond \
      --outputDir out \
      --scoreCutoff 50 \
      --titleRegex 'hbv|hepatitis' \
      --diamondDatabaseFastaFilename $dbFastaFile > summary-proteins
    echo "  noninteractive-alignment-panel.py stopped at `date`" >> $log

    echo "  proteins-to-pathogens.py started at `date`" >> $log
    echo summary-proteins | proteins-to-pathogens.py --proteinFastaFilename $dbFastaFile > summary-virus
    echo "  proteins-to-pathogens.py stopped at `date`" >> $log
}


if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Panel is being skipped on this run." >> $log
        skip
    elif [ -f $out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output file $out exists, but --force was used. Overwriting." >> $log
            panel
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist. Making panel." >> $log
        panel
    fi
fi

echo "04-panel stopped at `date`" >> $log
echo >> $log
