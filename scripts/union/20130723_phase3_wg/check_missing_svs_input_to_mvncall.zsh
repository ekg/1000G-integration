#!/bin/zsh
#
i=$1

tabix sv_gls/ALL.wgs.20130502.SV.low_coverage.genotypes.for-integration.flt-miss-50.vcf.gz $i | grep -v "^#" | cut -f -8 \
    | vcf2bed.py | bed2region | cut -f 1 \
    | parallel -j 16 'tabix mvncall/ALL.chr'$i'.mvncall_sorted_off_by_one.20130502.non_biallelic_snps_svs_microsat.genotypes.vcf.gz {} | cut -f 1-3' \
    | awk '{ if ($3 != ".") print; }' | sort --version-sort | uniq
