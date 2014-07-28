#!/bin/zsh
#

input=$1
pcrfree=$2
region=$3

tabix -h $input $region \
    | vcfannotate -b <(tabix -h $pcrfree $region | vcf2bed.py | sed s/\.$/TRUE/ ) -k PCRfree.any_variant -d FALSE
