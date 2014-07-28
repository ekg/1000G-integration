#!/bin/zsh
#

region=$1

vcfintersect -r ~/human_g1k_v37.fasta -i <(zcat mvncall_parsed.primitives.regions/$region.vcf.gz | vcfsnps | vcfbiallelic | cut -f -8) \
    <(zcat shapeit2.primitives.regions/$region.vcf.gz | vcfsnps | vcfbiallelic ) \
    | vcfannotategenotypes mvncall - <(zcat mvncall_parsed.primitives.regions/$region.vcf.gz | vcfsnps | vcfbiallelic ) \
    | vcf2tsv -g | tsvsplit GT mvncall | genoreorder.py | gzip >shapeit2_mvncall.gt_corr/$region.tsv.gz
