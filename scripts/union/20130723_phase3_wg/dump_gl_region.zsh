#!/bin/zsh
#
#
region=$1                         
seqname=$(echo $1 | cut -f 1 -d:) 
chrom=chr$(echo $1 | cut -f 1 -d:)
dir=$2                            

zcat $dir/$chrom/$region.vcf.gz
