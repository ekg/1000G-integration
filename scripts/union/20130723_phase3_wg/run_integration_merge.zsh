#!/bin/zsh
#

region=$1
chrom=$(echo $region | cut -f 1 -d:)

(
cat merged_header.txt

tabix -h non_biallelic_gls/ALL.chr$chrom.phase3_non_biallelic_snps.genotype_likelihoods.vcf.gz $region \
    | vcfkeepsamples - $(vcfsamplenames sv_gls/ALL.wgs.20130502.SV.low_coverage.genotypes.for-integration.flt-miss-50.vcf.gz ) \
    | grep -v "^#"

tabix -h sv_gls/ALL.wgs.20130502.SV.low_coverage.genotypes.for-integration.flt-miss-50.vcf.gz $region \
    | vcfglbound -b -10 -x | grep -v "^#"

#zcat lobstr/ALL.chr$chrom.lobSTR.20130502.microsat.integrated.imputation.vcf.gz \
tabix -h lobstr/ALL.wgs.lobSTR.20130502.microsat.integrated.genotypes.vcf.gz chr$region \
    | vcfintersect -v -b lobstr.str.exclude.bed \
    | sed "s/^chr//" \
    | awk '{ if ($5 != ".") print }' \
    | vcfkeepsamples - $(vcfsamplenames sv_gls/ALL.wgs.20130502.SV.low_coverage.genotypes.for-integration.flt-miss-50.vcf.gz ) \
    | vcfglbound -b -10 -x \
    | grep -v "^#"
) | vcf-sort -c
