#!/bin/zsh
#

region=$1
ref=$2
chrom=$(echo $region | cut -f 1 -d:)
chr=chr$chrom

svm=/d2/data/1000G/phaseIII/union.snps.svm/ALL.$chr.phase3.combined.sites.center.svm2.vcf.gz
integrated=/d2/data/1000G/phaseIII/merge/release_candidate_v2.chroms/ALL.$chr.genotypes.vcf.gz

zcat /d1/home/erik/tmp_vcf/phaseIII.wg.exlc.gls/$chr/$region.vcf.gz \
    | vcfintersect -b <(tabix -h $svm $region \
        | vcfintersect -r $ref -v -i <(tabix -h $integrated $region | cut -f -8 ) \
        | vcfgrep PASS | vcf2bed.py)
