#!/bin/zsh

region=$1
reference=$2
indir=$3

chrom=chr$(echo $region | cut -f 1 -d:)
infile=$indir/ALL.$chrom.passed.all.vcf.gz

tabix -h $infile $region \
    | grep -v "<CN\|<SV\|<INS\|<DEL\|<INV"  \
    | vt normalize -r ~/human_g1k_v37.fasta -q - \
    | vcfallelicprimitives --keep-geno --keep-info
