#!/bin/zsh
#

dir=$1
ref=$2

zcat $dir/bc/ALL.wgs.bc.20130502.snps_indels_mnps_complex.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/bcm/ALL.wgs.bcm.20130502.snps.integrated.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/bi/ALL.wgs.broad.assembly.20130502.snps_indels.low_coverage.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/bi/ALL.wgs.broad.mapping.20130502.snps_indels.low_coverage.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/lobstr/ALL.wgs.lobSTR.20130502.microsat.integrated.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/ox/ALL.wgs.oxford_platypus.20130502.snps_indels_mnps_cplx.low_coverage.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/si/ALL.wgs.samtools.20130502.snps_indels.low_coverage.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/si/ALL.wgs.sga-dindel.20130502.snps_indels_mnps_cmplx.low_coverage.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/stn/ALL.wgs.stanford_rtg.20130503.snps_indels.low_coverage.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/um/ALL.wgs.gotcloud.20130502.indels.integrated.sites.PASS.primitives.vcf.gz \
    | vcfintersect -r $ref -u $dir/um/ALL.wgs.gotcloud.20130502.snps.integrated.sites.PASS.primitives.vcf.gz
