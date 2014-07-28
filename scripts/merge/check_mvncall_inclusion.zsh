#!/bin/zsh
#

region=$1

vcfintersect -r ~/human_g1k_v37.fasta -vi  <(zcat shapeit2_mvncall_overlay/$region.vcf.gz |cut -f -8 ) <(zcat mvncall_parsed.primitives.regions/$region.vcf.gz | cut -f -8) 
