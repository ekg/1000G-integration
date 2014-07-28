#!/bin/zsh
#

vcfintersect -v -b exclude_from_training.bed \
    | grep -v "<CN" | grep -v "<SV" | grep -v "<INS" | grep -v "<DEL" | grep -v "<INV" \
    | vcfbiallelic \
    | genoreorder.py 2>/dev/null \
    | vcf2tsv -g -n "NA" \
    | tsvsplit PCRfree.has_variant MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter AB DP QA QR PAIRED PAIREDR QUAL.fb \
    | ./tsv2libsvm.py 2>/dev/null
