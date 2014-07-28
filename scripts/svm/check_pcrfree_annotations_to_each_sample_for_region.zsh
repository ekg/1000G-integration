#!/bin/zsh
#

samplelist=$1
region=$2
outdir=$3

for sample in $(cat $samplelist);
do
    if [ ! -f $outdir/$sample/$region.vcf.gz.tbi ];
    then
        echo $sample $region
    fi
done
