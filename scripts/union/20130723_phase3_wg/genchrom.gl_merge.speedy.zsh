#!/bin/zsh

chrom=$1
dir=$2

(
firstregion=$(grep "^$chrom:" phase3.even.regions | head -1)
zcat $dir/$firstregion.vcf.gz | head -1000 | grep "^#"

for region in $(grep "^$chrom:" phase3.even.regions );
do
    chrom=$(echo $region | cut -f 1 -d:)
    start=$(echo $region | cut -f 2 -d: | cut -f 1 -d-)
    end=$(echo $region | cut -f 2 -d: | cut -f 2 -d-)
    end=$(echo "$end - 1" | bc)
    minus_1bp_region="$chrom:$start-$end"
    zcat $dir/$region.vcf.gz \
        | vcfintersect -S -R $minus_1bp_region \
        | grep -v "^#"
done
)
