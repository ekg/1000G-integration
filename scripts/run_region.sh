#!/bin/bash


if [ $# -ne 8 ];
then
    echo "usage: $0 [outdir] [reference] [region] [union] [contamination] [cnvmap] [scratch] [merge_script]"
    exit
fi

## Change this to your 1000G-integration directory, or remove if
## you put freebayes and glia into your system-wide path:
bin=/share/home/erik/1000G-integration/bin

outdir=$1
reference=$2
region=$3
union=$4
contamination=$5
cnvmap=$6
scratch=$7
merger=$8

mkdir -p $outdir

mkdir -p $scratch
realigned_bam=$scratch/$region.bam

# determine expanded region, needed to remove edge effects from realignment
overlap=500  # we should use at least half the default realignment window size
chrom=$(echo $region | cut -f 1 -d:)
begin=$(echo $region | cut -f 2 -d: | cut -f 1 -d-)
end=$(echo $region | cut -f 2 -d: | cut -f 2 -d-)

if [ $begin -ne 0 ];
then
    begin=$(echo "$begin - $overlap" | bc)
fi
end=$(echo "$end + $overlap" | bc)

expandedregion="$chrom:$begin-$end"


# $merger should be a script which merges a single region ($region) of your BAM
# files.  For the distributed GL compute, the input should be a merge of all
# exome and low-coverage data across all samples.

$merger $expandedregion \
    | $bin/glia -Rr -w 1000 -S 200 -Q 200 -G 4 -f $reference -v $union \
        2>$outdir/$region.glia.err \
    | samtools view -b - >$realigned_bam

samtools index $realigned_bam 2>$outdir/$region.samtools.index.err

$bin/freebayes -f $reference --region $region \
        --min-alternate-fraction 0.2 \
        --min-alternate-count 2 \
        --min-mapping-quality 1 \
        --min-base-quality 3 \
        --min-repeat-entropy 1 \
        --genotyping-max-iterations 10 \
        --contamination-estimates $contamination \
        --cnv-map $cnvmap \
        --haplotype-basis-alleles $union \
        $realigned_bam \
        2>$outdir/$region.freebayes.err \
    | gzip >$outdir/$region.vcf.gz

zcat $outdir/$region.vcf.gz \
    | cut -f -8 | gzip >$outdir/$region.sites.vcf.gz \
        && touch $outdir/$region.done

zcat $outdir/$region.vcf.gz >/dev/null && touch $outdir/$region.ok

rm $realigned_bam{,.bai}
