#!/bin/zsh
#

region=$1
outdir=$2
ref=$3
chrom=chr$(echo $region | cut -f 1 -d:)

( # the mvncall and SV results

    # small variants
    (
        # get the sites which we kept from the first mvncall run
        tabix -h /d2/data/1000G/phaseIII/union/20130723_phase3_wg/mvncall/ALL.$chrom.mvncall_sorted_off_by_one.20130502.non_biallelic_snps_svs_microsat.genotypes.vcf.gz $region \
            | grep -v pindel \
            | vcfintersect -r $ref -i <( zcat /d2/data/1000G/phaseIII/svm/svmed.filtered.sites_to_keep/$region.vcf.gz | cut -f -8 )

        # and get the rest, which had some alleles filtered
        # these were imputed again into the remaining allele set
        # note that we exclude the pindel SVs
        tabix /d2/data/1000G/phaseIII/merge/mvncall_output_2nd_fixed/ALL.$chrom.phase3_shapeit2_mvncall_fixed2.20130502.genotypes.vcf.gz $region | grep -v pindel

        # and the final patched SNPs, which appeared multiallelic but were genotyped as biallelic
        # erroneously omitted--- these are SVM PASS results from Hyun's SNP filtering
        tabix -h /d2/data/1000G/phaseIII/merge/missing_biallelic_mvncall/ALL.$chrom.missing_biallelic_snps.20130502.genotypes.vcf.gz $region \
            | vcfkeepinfo - NA | vcfkeepgeno - GT \
            | grep -v "^#"

    ) \
    | vcf-sort -c \
    | grep -v "<CN\|<SV\|<INS\|<DEL\|<INV" \
    | vcfallelicprimitives --keep-geno --keep-info \
    | vt normalize -r ~/human_g1k_v37.fasta -q - \
    | vcfkeepinfo - NA \
    | vcfkeepgeno - GT \
    | vcffixup - \
    | vcffilter -f "AC > 0"


    # get the SVs from shapeit2 and previous (pre-SVM) mvncall run
    #(
    #    tabix -h /d2/data/1000G/phaseIII/union/20130723_phase3_wg/shapeit2/ALL.$chrom.phase3_shapeit2_integrated.20130502.snps_indels_svs.genotypes.vcf.gz $region
    #    tabix -h /d2/data/1000G/phaseIII/union/20130723_phase3_wg/mvncall/ALL.$chrom.mvncall_sorted_off_by_one.20130502.non_biallelic_snps_svs_microsat.genotypes.vcf.gz $region
    #) \
    #| grep "^##\|^#CHROM\|<" | grep -v "^#"

)  | vcf-sort -c | uniq | bgziptabix $outdir/$region.mvncall.vcf.gz


( # the shapeit2 biallelic SNP and indel results (non SV)
# note removal of sites that are multiallelic in the MVNCall set
tabix -h /d2/data/1000G/phaseIII/union/20130723_phase3_wg/shapeit2/ALL.$chrom.phase3_shapeit2_integrated.20130502.snps_indels_svs.genotypes.vcf.gz $region \
    | grep -v "<CN\|<SV\|<INS\|<DEL\|<INV" \
    | vcfallelicprimitives --keep-geno --keep-info \
    | vcfintersect -v -b <(zcat $outdir/$region.mvncall.vcf.gz | cut -f -8 | vcfmultiallelic | vcf2bed.py) \
    | vt normalize -r ~/human_g1k_v37.fasta -q - \
    | vcfkeepinfo - NA \
    | vcffixup - \
    | vcffilter -f "AC > 0"
) | bgziptabix $outdir/$region.shapeit2.vcf.gz

vcfoverlay $outdir/$region.shapeit2.vcf.gz $outdir/$region.mvncall.vcf.gz | bgziptabix $outdir/$region.vcf.gz

zcat $outdir/$region.vcf.gz | cut -f -8 | bgziptabix $outdir/$region.sites.vcf.gz


