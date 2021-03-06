#!/bin/zsh
#

dir=$1
region=$2

vcfcombine <(tabix -h $dir/bc/ALL.wgs.bc.20130502.snps_indels_mnps_complex.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  ) \
    <(tabix -h $dir/bcm/ALL.wgs.bcm.20130502.snps.integrated.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  ) \
    <(tabix -h $dir/bi/ALL.wgs.broad.assembly.20130502.snps_indels.low_coverage.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  ) \
    <(tabix -h $dir/bi/ALL.wgs.broad.mapping.20130502.snps_indels.low_coverage.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  ) \
    <(tabix -h $dir/ox/ALL.wgs.oxford_platypus.20130502.snps_indels_mnps_cplx.low_coverage.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  ) \
    <(tabix -h $dir/si/ALL.wgs.samtools.20130502.snps_indels.low_coverage.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  ) \
    <(tabix -h $dir/si/ALL.wgs.sga-dindel.20130502.snps_indels_mnps_cmplx.low_coverage.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  ) \
    <(tabix -h $dir/stn/ALL.wgs.stanford_rtg.20130503.snps_indels.low_coverage.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  ) \
    <(tabix -h $dir/um/ALL.wgs.gotcloud.20130502.indels.integrated.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  ) \
    <(tabix -h $dir/um/ALL.wgs.gotcloud.20130502.snps.integrated.sites.PASS.snps.vcf.gz $region | vcfcreatemulti  )
