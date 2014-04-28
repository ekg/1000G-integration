#!/bin/zsh
#

if [ $# -eq 0 ]; then; cat $0; exit; fi

input=$1
pcrfree=$2
region=$3

tabix -h $input $region \
    | vcflength \
    | vcffilter -f "AC > 0" | vcfallelicprimitives --keep-info --keep-geno \
    | vcfkeepgeno - GT AVGPOST | grep -v PL \
    | vt normalize -r ~/human_g1k_v37.fasta - \
    | vcfannotategenotypes PCRfree - <(tabix -h $pcrfree $region | vcfglxgt | vcfallelicprimitives | vt normalize -r ~/human_g1k_v37.fasta -) \
    | vcfintersect -r ~/human_g1k_v37.fasta -M AO -T AO.PCRfree -i <(tabix -h $pcrfree $region | vcfallelicprimitives --keep-info | vt normalize -r ~/human_g1k_v37.fasta -) \
    | vcfintersect -r ~/human_g1k_v37.fasta -M RO -T RO.PCRfree -i <(tabix -h $pcrfree $region | vcfallelicprimitives --keep-info | vt normalize -r ~/human_g1k_v37.fasta -) \
    | vcfannotate -b <(tabix -h $pcrfree $region | vcf2bed.py | sed s/\.$/TRUE/ ) -k PCRfree.any_variant -d FALSE
