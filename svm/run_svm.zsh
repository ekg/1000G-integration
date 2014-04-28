#!/bin/zsh
#

out=$1

for sample in $(cat trio_and_ceu.sample.names; cat validation.sample.names )
do
    zcat samples/$sample.chr20.non_biallelic_snps.annotated+PCRfree.vcf.gz \
        | vcfbiallelic \
        | genoreorder.py 2>/dev/null \
        | vcf2tsv -g -n "NA" \
        | tsvsplit PCRfree.has_variant MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter AB DP QA QR PAIRED PAIREDR QUAL.fb \
        | ./tsv2libsvm.py 2>/dev/null \
        | head -10000
done >$out.dat 

cat $out.dat | shuf >$out.shuf.dat
cat $out.shuf.dat | tail -25000 >$out.shuf.25000.test.libsvm
cat $out.shuf.dat | head -25000 >$out.shuf.25000.train.libsvm

echo "running svm easy"
time svm-easy.py $out.shuf.25000.train.libsvm $out.shuf.25000.test.libsvm

svm-scale -s $out.shuf.25000.train.libsvm.range $out.shuf.25000.train.libsvm >$out.shuf.25000.train.libsvm.scale
svm-scale -r $out.shuf.25000.train.libsvm.range $out.shuf.25000.test.libsvm >$out.shuf.25000.test.libsvm.scale


exit

time svm-train -c 8 -g 2 -h 0 -b 1 $out.shuf.25000.train.libsvm.scale $out.shuf.25000.train.libsvm.model
svm-predict -b 1 $out.shuf.25000.test.libsvm.scale $out.shuf.25000.train.libsvm.model $out.shuf.25000.test.libsvm.predict
#zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | vcfbiallelic | genoreorder.py | vcf2tsv -n "NA" | tsvsplit PCRfree.has_variant MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter AB DP QA QR PAIRED PAIREDR QUAL.fb | pv -l | ./tsv2libsvm.py >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm 
zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | cut -f -8 | genoreorder.py | vcf2tsv -n "NA" | tsvsplit CHROM POS REF ALT MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter AB DP QA QR PAIRED PAIREDR QUAL.fb >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.tsv
cat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.tsv | cut -f 5- | prependcol NULL 0 | pv -l | ./tsv2libsvm.py >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input 
svm-scale -r $out.shuf.25000.train.libsvm.range ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.scale
svm-predict -b 1 ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.scale $out.shuf.25000.train.libsvm.model ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.predict
zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | cut -f -8 | head -1000 | grep "^#"  >header.vcf
( cat header.vcf; paste <(cat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.tsv | tsvsplit CHROM POS REF ALT | tail -n+2 | awk 'BEGIN { OFS="\t" } { print $1, $2, ".", $3, $4, 0, "." }' ) <(tail -n+2 ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.predict | awk '{ print "SVM1="$2";SVM0="$3 }') ) | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.predict.svm.vcf.gz

zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | cut -f -8 | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz
zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz | vcfintersect -M SVM1 -T SVM1 -i ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz -r ~/human_g1k_v37.fasta | less -S 

zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | cut -f -8 | genoreorder.py | vcf2tsv -n "NA" | tsvsplit CHROM POS REF ALT MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter AB DP QA QR PAIRED PAIREDR QUAL.fb >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.tsv
cat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.tsv | cut -f 5- | prependcol NULL 0 | pv -l | ./tsv2libsvm.py >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all  
svm-scale -r $out.shuf.25000.train.libsvm.range ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.scale
svm-predict -b 1 ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.scale $out.shuf.25000.train.libsvm.model ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict

( cat header.vcf; paste <(cat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.tsv | tsvsplit CHROM POS REF ALT | tail -n+2 | awk 'BEGIN { OFS="\t" } { print $1, $2, ".", $3, $4, 0, "." }' ) <(tail -n+2 ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict | awk '{ print "SVM1="$2";SVM0="$3 }') ) | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict.svm.vcf.gz &
zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz | vcfintersect -M SVM1 -T SVM1 -i ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict.svm.vcf.gz -r ~/human_g1k_v37.fasta | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.svm.vcf.gz &

zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz | vcfintersect -M SVM1 -T SVM1 -i ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict.svm.vcf.gz -r ~/human_g1k_v37.fasta | sed "s/ID=SVM1,Number=A,Type=String,Description=/ID=SVM1,Number=A,Type=Float,Description=/" | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.svm.vcf.gz &


