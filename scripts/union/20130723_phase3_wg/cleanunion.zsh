#!/bin/zsh
#
# cleans union allele list

ref=$1

# steps:
# 
# exclude records with REF fields != the reference
# annotate the alleles with type information
# strip the info
# make primitive alleles
# convert to single-allele per line format
# then use sort/uniq to remove duplicates
# create multiallelic records where alleles overlap
# and assert that we only want the sites

vcfcheck -f $ref -x \
    | vcfstats -a \
    | vcfkeepinfo - type \
    | cut -f -8 \
    | sed 's/;$//' \
    | vcfleftalign -r $ref \
    | vcfallelicprimitives \
    | vcfbreakmulti \
    | vcfstreamsort \
    | vcfuniq \
    | vcfcreatemulti \
    | cut -f -8
