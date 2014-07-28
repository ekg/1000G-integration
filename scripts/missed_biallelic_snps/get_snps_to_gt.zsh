#!/bin/zsh
#

region=$1
ref=$2
chr=chr$(echo $region | cut -f 1 -d:)

tabix -h missed_svm_pass_snps_loci.chroms/ALL.$chr.genotype_likelihoods.vcf.gz $region \
    | vcfintersect -r $ref -i <(./get_missed_svm.zsh $region $ref )
