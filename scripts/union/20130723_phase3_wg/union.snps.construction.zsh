#!/bin/zsh
#
# construction of union snps
#
# 2 phases, union generation then annotation of SNPs
# particular importance is the cleaning process

mkdir -p /d2/data/1000G/phaseIII/union/20130723_phase3_wg/chroms ; echo $(seq 1 22) X Y | tr ' ' '\n' | parallel -j 10 'zcat chroms/{}.snps.vcf.gz | vcfbreakmulti | vcfnoNs | vcfstreamsort | vcfuniq | vcfkeepinfo - na | vcfcreatemulti | vcfstats -a | vcfkeepinfo - type | sed "s/;$//" | ./annotateunion.tabix.snps.zsh /d2/data/1000G/phaseIII/union/20130723_phase3_wg/ ~/human_g1k_v37.fasta {} | bgziptabix chroms/{}.snps.annotated.vcf.gz '

mkdir -p /d2/data/1000G/phaseIII/union/20130723_phase3_wg/chroms ; echo $(seq 1 22) X Y | tr ' ' '\n' | parallel -j 24 './genunion.tabix.combine.snps.zsh /d2/data/1000G/phaseIII/union/20130723_phase3_wg/ {} | cut -f -7 | sed s/FILTER/FILTER\\tINFO/ | vcfbreakmulti | vcfstreamsort | vcfuniq | vcfcreatemulti | vcfstats -a | vcfkeepinfo - type | sed "s/;$//" | bgziptabix chroms/{}.snps.vcf.gz '

# merge

( cat header.3; vcfcat $(echo $(seq 1 22) X Y | tr ' ' '\n' | parallel -k 'echo chroms/{}.snps.annotated.vcf.gz' | tr '\n' ' ') | grep -v "^#" ) | bgziptabix ALL.wgs.phase3_bc_union.20130502.snps.sites.vcf.gz

# biallelic only

zcat ALL.wgs.phase3_bc_union.20130502.snps.sites.vcf.gz | vcfbiallelic | bgziptabix ALL.wgs.phase3_bc_union.20130502.biallelic_snps.sites.vcf.gz

# validate set against SVM


