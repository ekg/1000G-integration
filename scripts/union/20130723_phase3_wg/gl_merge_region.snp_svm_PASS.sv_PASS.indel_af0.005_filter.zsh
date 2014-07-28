#!/bin/zsh

region=$1
chrom=$(echo $region | cut -f 1 -d:)

vcfcombine \
    <(tabix -h /d2/data/1000G/phaseIII/union/20130723_phase3_wg/union_gls/ALL.chr$chrom.phase3_bc_union.20130502.biallelic_snps.gl.vcf.gz $region \
        | vcfintersect -b <(tabix -h /d2/data/1000G/phaseIII/union/20130723_phase3_wg/filtered/ALLchr$chrom.phase3_um_svm_filtered.20130502.biallelic_snps.integrated.sites.vcf.gz $region \
                            | vcfgrep PASS | vcf2bed.py) ) \
    <(tabix -h /d2/data/1000G/phaseIII/union/20130723_phase3_wg/union_gls/ALL.wgs.phase3_dels_merged_genome_strip.20130502.dels.low_coverage.genotypes.GL.vcf.gz $region \
        | vcfgrep PASS) \
    <(tabix -h /d2/data/1000G/phaseIII/union/20130723_phase3_wg/indel_gls/ALL.chr$chrom.phase3_bc_union.20130502.3of9_or_assembly.indels.gl.vcf.gz $region \
        | vcfglxgt -n | arfer | vcffilter -f "AFmle > 0.005" | vcffilter -t PASS -f "1 = 1" | vcfkeepinfo - NA ) \
    | vcfkeepgeno - GL
