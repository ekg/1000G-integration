#!/bin/zsh
#

samplelist=$1
regionfile=$2
outdir=$3

for sample in $(cat $samplelist);
do
    mkdir -p $outdir/$sample
    zcat $regionfile | vcfkeepsamples - $sample | vcffixup - | vcffilter -f "AC > 0" | bgziptabix $outdir/$sample/$(basename $regionfile)
done
