#!/bin/zsh
#

regions=/share/home/erik/runs/phaseIII.wg.exlc.gls/completed.indel_gl.regions
# chrom number
N=$1

( ./dump_gl_region.zsh $(grep "^$N:" $regions | head -1) /d1/home/erik/tmp_vcf/phaseIII.wg.exlc.gls \
    | head -200 | grep "^#"
grep "^$N:" $regions \
    | parallel -j 40 -k './dump_gl_region.zsh {} /d1/home/erik/tmp_vcf/phaseIII.wg.exlc.gls | vcfnobiallelicsnps | grep -v "^#"' ) \
    | bgziptabix ALL.chr$N.phase3_non_biallelic_snps.genotype_likelihoods.vcf.gz
