#!/bin/zsh

region=$1
reference=$2
indir=$3

chrom=chr$(echo $region | cut -f 1 -d:)
infile=$indir/ALL.$chrom.phase3_shapeit2_integrated.20130502.snps_indels_svs.genotypes.vcf.gz

tabix -h $infile $region \
    | grep -v "<CN\|<SV\|<INS\|<DEL\|<INV"  \
    | vcfallelicprimitives --keep-geno --keep-info \
    | vt normalize -r ~/human_g1k_v37.fasta -q -
