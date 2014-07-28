#!/bin/zsh
#

region=$1
ref=$2
chrom=$(echo $region | cut -f 1 -d:)
chr=chr$chrom
pos=$(echo $region | cut -f 2 -d: | cut -f 1 -d\-)

svm=/d2/data/1000G/phaseIII/union.snps.svm/ALL.$chr.phase3.combined.sites.center.svm2.vcf.gz
integrated=/d2/data/1000G/phaseIII/merge/release_candidate_v2.chroms/ALL.$chr.genotypes.vcf.gz
regions=~/1000G-integration/resources/regions/20files.$chr.even_coverage.regions
target=$(cat $regions | tr : ' ' | tr - ' ' | awk '{ if ($2 < '$pos' && $3 > '$pos') print $1":"$2"-"$3; }' )

echo $target

zcat /d1/home/erik/tmp_vcf/phaseIII.wg.exlc.gls/$chr/$target.vcf.gz | vcfintersect -R $region
