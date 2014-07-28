#!/bin/zsh
#


chrom=$1
cpus=$2
dir=$3

( zcat $dir/$(grep "^$1:" union.1000.even_regions | head -1).vcf.gz | head -1000 | grep "^#"

grep "^$1:" union.1000.even_regions \
    | parallel -k -j $cpus "zcat $dir/{}.vcf.gz | grep -v '^#'"
) | vcf-sort -c -p $cpus | uniq
