#!/bin/zsh
#

samplelist=$1
region=$2
indir=$3
pcrfreebase=$4
outdir=$5

for sample in $(cat $samplelist);
do
    mkdir -p $outdir/$sample
    ./annotate_region_primitives.zsh $indir/$sample/$region.vcf.gz $pcrfreebase/$sample.wgs.freebayes.vcf.gz $region \
        | bgziptabix $outdir/$sample/$region.vcf.gz
done
