#!/bin/zsh

if [ $# -eq 0 ]; then; cat $0; exit; fi

region=$1
chr=$(echo $region | cut -f 1 -d:)

tabix -h /d2/data/1000G/phaseIII/union/20130723_phase3_wg/union_gls/ALL.chr$chr.phase3_bc_union.20130502.biallelic_snps.gl.vcf.gz $region \
    | vcfintersect -r ~/human_g1k_v37.fasta -i \
        <(tabix -h /d2/data/1000G/phaseIII/union.snps.svm/ALL.chr$chr.phase3.combined.sites.center.svm2.vcf.gz $region \
            | vcfgrep PASS \
            | vcfintersect -r ~/human_g1k_v37.fasta -v -i \
            <(tabix -h /d2/data/1000G/phaseIII/merge/shapeit2_mvncall_overlay.chroms/ALL.chr$chr.svmed.genotypes.vcf.gz $region | cut -f -8 | vcfsnps ) )
