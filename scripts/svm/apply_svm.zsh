#!/bin/zsh
#

if [ $# -eq 0 ]; then; cat $0; exit; fi

svm_model=$1
svm_range=$2
reference=$3
region=$4
annotated_vcf_dir=$5
out=$6

annotated_vcf=$annotated_vcf_dir/$region.vcf.gz
output_vcf=$out/$region.vcf.gz

mkdir -p $out

libsvm_input_tsv=$out/$region.libsvm.input.tsv
libsvm_input=$out/$region.libsvm.input

# 1) prepare input VCF by adding annotations from freebayes VCF which are used by SVM
# DONE now, we're using the pre-annotated VCF

# 2) extract data for use by model
zcat $annotated_vcf \
    | cut -f -8 | ./genoreorder.py | vcf2tsv -n "NA" \
    | tsvsplit CHROM POS REF ALT MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter AB DP QA QR PAIRED PAIREDR QUAL.fb >$libsvm_input_tsv

cat $libsvm_input_tsv | cut -f 5- | prependcol NULL 0 | pv -l | ./tsv2libsvm.py >$libsvm_input

libsvm_input_scaled=$libsvm_input.scale
svm-scale -r $svm_range $libsvm_input >$libsvm_input_scaled

libsvm_prediction=$out/$region.libsvm.predict
svm-predict -b 1 $libsvm_input_scaled $svm_model $libsvm_prediction

svm_annotated_vcf=$out/$region.libsvm.predict.svm.vcf.gz
( cat header.vcf
  paste <(cat $libsvm_input_tsv | tsvsplit CHROM POS REF ALT | tail -n+2 | awk 'BEGIN { OFS="\t" } { print $1, $2, ".", $3, $4, 0, "." }' ) \
      <(tail -n+2 $libsvm_prediction | awk '{ print "SVM1="$3";SVM0="$2 }') ) | bgziptabix $svm_annotated_vcf


zcat $annotated_vcf \
    | vcfintersect -M SVM1 -T SVM1 -i $svm_annotated_vcf -r $reference \
    | sed "s/ID=SVM1,Number=A,Type=String,Description=/ID=SVM1,Number=A,Type=Float,Description=/" \
    | bgziptabix $output_vcf


rm $libsvm_input $libsvm_input_scaled $libsvm_prediction $libsvm_input_tsv $svm_annotated_vcf{,.tbi}
