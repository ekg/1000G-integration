#!/bin/zsh
#

input=$1
pcrfree=$2
region=$3

tabix -h NA12878.chr20.non_biallelic_snps.streamsort.vcf.gz $region \
    | vcffilter -f "AC > 0" \
    | vcfannotategenotypes PCRfree - <(tabix -h $pcrfree $region ) \
    | vcfintersect -r ~/human_g1k_v37.fasta -M AO -T AO.PCRfree -i <(tabix -h $pcrfree $region ) \
    | vcfintersect -r ~/human_g1k_v37.fasta -M RO -T RO.PCRfree -i <(tabix -h $pcrfree $region )
