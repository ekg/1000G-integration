#!/bin/zsh

chrom=$1
vcfcombine $(for file in $(grep "^$chrom:" phase3.even.regions ); do echo -n " gl_merge.indel_af0.005.regions/$file.vcf.gz" ; done) \
    | vcfuniq
