#!/bin/zsh

if [ $# -eq 0 ]; then; cat $0; exit; fi

gldir=$1
indir=$2
outdir=$3
region=$4
chr=$(echo $region | cut -f 1 -d:)

mkdir -p $outdir/tmp
tmpvcf=$outdir/tmp/$region.vcf

zcat $indir/$region.vcf.gz | cut -f -8 | vcfgrep CIGAR | vcfkeepinfo - SVM1 AC.pop >$tmpvcf

tabix -h $gldir/ALL.chr$chr.snps_indels_complex_STRs_svs.genotype_likelihoods.vcf.gz $region \
    | vcfintersect -r ~/human_g1k_v37.fasta -i $tmpvcf -M SVM1 -T SVM1 \
    | vcfintersect -r ~/human_g1k_v37.fasta -i $tmpvcf -M AC.pop -T AC.pop \
    | vcfgrep CIGAR \
    | sed "s/^##INFO=<ID=SVM1,Number=A,Type=String/##INFO=<ID=SVM1,Number=A,Type=Float/" \
    | sed "s/^##INFO=<ID=AC.pop,Number=A,Type=String/##INFO=<ID=AC.pop,Number=A,Type=Integer/" \
    | vcffilter -f "( ( TYPE = ins | TYPE = del ) & SVM1 > 0.665 & AC.pop > 2 ) | ( TYPE = snp & SVM1 > 0.775 & AC.pop > 1 ) | ( TYPE = mnp & SVM1 > 0.635 & AC.pop > 1 ) | ( TYPE = complex & SVM1 > 0.845 & AC.pop > 3 )" \
    | vcfkeepgeno - GT GL \
    | vcfkeepinfo - AC.pop AC SVM1 TYPE NUMALT DP CIGAR \
    | bgziptabix $outdir/$region.vcf.gz

rm $tmpvcf
