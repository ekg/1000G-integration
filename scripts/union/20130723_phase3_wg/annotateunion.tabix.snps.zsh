#!/bin/zsh
#

dir=$1
ref=$2
region=$3

vcfintersect -w 3 -r $ref -t bc.freebayes -V 1 -i <(tabix -h $dir/bc/ALL.wgs.bc.20130502.snps_indels_mnps_complex.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | vcfintersect -w 3 -r $ref -t bcm.snptools -V 1 -i <(tabix -h $dir/bcm/ALL.wgs.bcm.20130502.snps.integrated.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | vcfintersect -w 3 -r $ref -t broad.assembly -V 1 -i <(tabix -h $dir/bi/ALL.wgs.broad.assembly.20130502.snps_indels.low_coverage.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | vcfintersect -w 3 -r $ref -t broad.mapping -V 1 -i <(tabix -h $dir/bi/ALL.wgs.broad.mapping.20130502.snps_indels.low_coverage.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | vcfintersect -w 3 -r $ref -t ox.platypus -V 1 -i <(tabix -h $dir/ox/ALL.wgs.oxford_platypus.20130502.snps_indels_mnps_cplx.low_coverage.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | vcfintersect -w 3 -r $ref -t si.samtools -V 1 -i <(tabix -h $dir/si/ALL.wgs.samtools.20130502.snps_indels.low_coverage.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | vcfintersect -w 3 -r $ref -t si.sgadindel -V 1 -i <(tabix -h $dir/si/ALL.wgs.sga-dindel.20130502.snps_indels_mnps_cmplx.low_coverage.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | vcfintersect -w 3 -r $ref -t stanford.rtg -V 1 -i <(tabix -h $dir/stn/ALL.wgs.stanford_rtg.20130503.snps_indels.low_coverage.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | vcfintersect -w 3 -r $ref -t um.indels -V 1 -i <(tabix -h $dir/um/ALL.wgs.gotcloud.20130502.indels.integrated.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | vcfintersect -w 3 -r $ref -t um.snps -V 1 -i <(tabix -h $dir/um/ALL.wgs.gotcloud.20130502.snps.integrated.sites.PASS.snps.vcf.gz $region | cut -f -7 ) \
    | cut -f -8
