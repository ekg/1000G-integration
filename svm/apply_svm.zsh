#!/bin/zsh
#

svm_model=$1
mvncall_vcf=$2
freebayes_gls_vcf=$3
reference=$4
region=$5
svm_range=$6

annotated_vcf=$(basename $mvncall_vcf .vcf.gz).$region.annotated_from_original_gls.vcf.gz
libsvm_input_tsv=$(basename $annotated_vcf .vcf.gz).libsvm.input.tsv
libsvm_input=$(basename $annotated_vcf .vcf.gz).libsvm.input

# 1) prepare input VCF by adding annotations from freebayes VCF which are used by SVM
./annotate_phased.zsh $mvncall_vcf $freebayes_gls_vcf $reference $region | bgziptabix $annotated_vcf

# 2) extract data for use by model
zcat $annotated_vcf \
    | cut -f -8 | ./genoreorder.py | vcf2tsv -n "NA" \
    | tsvsplit CHROM POS REF ALT MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter AB DP QA QR PAIRED PAIREDR QUAL.fb >$libsvm_input_tsv

cat $libsvm_input_tsv | cut -f 5- | prependcol NULL 0 | pv -l | ./tsv2libsvm.py >$libsvm_input

libsvm_input_scaled=$libsvm_input.scale
svm-scale -r $svm_range $libsvm_input >$libsvm_input_scaled

libsvm_prediction=$(basename $libsvm_input .input).predict
svm-predict -b 1 $libsvm_input_scaled $svm_model $libsvm_prediction

svm_annotated_vcf=$(basename $mvncall_vcf .vcf.gz).libsvm.predict.svm.vcf.gz
( cat header.vcf
  paste <(cat $libsvm_input_tsv | tsvsplit CHROM POS REF ALT | tail -n+2 | awk 'BEGIN { OFS="\t" } { print $1, $2, ".", $3, $4, 0, "." }' ) \
      <(tail -n+2 $libsvm_input | awk '{ print "SVM1="$2";SVM0="$3 }') ) | bgziptabix $svm_annotated_vcf


output_vcf=$(basename $mvncall_vcf .vcf.gz).$region.SVMed.sites.vcf.gz
zcat $annotated_vcf \
    | vcfintersect -M SVM1 -T SVM1 -i $svm_annotated_vcf -r $reference \
    | sed "s/ID=SVM1,Number=A,Type=String,Description=/ID=SVM1,Number=A,Type=Float,Description=/" \
    | bgziptabix $output_vcf


