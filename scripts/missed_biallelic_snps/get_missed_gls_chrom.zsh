#!/bin/zsh

i=$1

( zcat /d1/home/erik/tmp_vcf/phaseIII.wg.exlc.gls/chr1/1:0-31717.vcf.gz | head -100 | grep "^#"
  cat ~/1000G-integration/resources/regions/20files.chr$i.even_coverage.regions | parallel -j 50 './gls_for_missed.zsh {} ~/human_g1k_v37.fasta  | grep -v "^#"' ) \
      | vcf-sort -c -t sortdir -p 10 | vcfuniq
