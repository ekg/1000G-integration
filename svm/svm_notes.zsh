#!/bin/zsh

: 1394515775:0;for sample in $(cat trio_and_ceu.sample.names; cat validation.sample.names ); do zcat samples/$sample.chr20.non_biallelic_snps.annotated+PCRfree.vcf.gz | vcfbiallelic | genoreorder.py | vcf2tsv -g -n "NA" | tsvsplit PCRfree.has_variant MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter HWEpval AB DP QA QR PAIRED PAIREDR QUAL.fb | ./tsv2libsvm.py | head -10000 ; done >28_samples.10000per.15param.dat 
: 1394517394:0;cat 28_samples.10000per.15param.dat | shuf >28_samples.10000per.15param.shuf.dat
: 1394519787:0;cat 28_samples.10000per.15param.shuf.dat | tail -25000 >28_samples.10000per.15param.shuf.25000.test.libsvm
: 1394519799:0;cat 28_samples.10000per.15param.shuf.dat | head -25000 >28_samples.10000per.15param.shuf.25000.train.libsvm
: 1394519787:0;cat 28_samples.10000per.15param.shuf.dat | tail -25000 >28_samples.10000per.15param.shuf.25000.test.libsvm
: 1394519799:0;cat 28_samples.10000per.15param.shuf.dat | head -25000 >28_samples.10000per.15param.shuf.25000.train.libsvm
: 1394520474:0;time ./easy.py /d2/data/1000G/phaseIII/union/20130723_phase3_wg/MVNcall_testing/28_samples.10000per.15param.shuf.25000.train.libsvm /d2/data/1000G/phaseIII/union/20130723_phase3_wg/MVNcall_testing/28_samples.10000per.15param.shuf.25000.test.libsvm
: 1394538784:0;svm-scale -s 28_samples.10000per.15param.shuf.25000.train.libsvm.range 28_samples.10000per.15param.shuf.25000.train.libsvm >28_samples.10000per.15param.shuf.25000.train.libsvm.scale
: 1394538798:0;svm-scale -r 28_samples.10000per.15param.shuf.25000.train.libsvm.range 28_samples.10000per.15param.shuf.25000.test.libsvm >28_samples.10000per.15param.shuf.25000.test.libsvm.scale
: 1394538848:0;time svm-train -c 8 -g 2 -h 0 -b 1 28_samples.10000per.15param.shuf.25000.train.libsvm.scale 28_samples.10000per.15param.shuf.25000.train.libsvm.model
: 1394541147:0;svm-predict -b 1 28_samples.10000per.15param.shuf.25000.test.libsvm.scale 28_samples.10000per.15param.shuf.25000.train.libsvm.model 28_samples.10000per.15param.shuf.25000.test.libsvm.predict
: 1394542556:0;zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | vcfbiallelic | genoreorder.py | vcf2tsv -n "NA" | tsvsplit PCRfree.has_variant MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter HWEpval AB DP QA QR PAIRED PAIREDR QUAL.fb | pv -l | ./tsv2libsvm.py >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm 
#: 1394542641:0;zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | vcfbiallelic | genoreorder.py | vcf2tsv -n "NA" | tsvsplit CHROM POS REF ALT MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter HWEpval AB DP QA QR PAIRED PAIREDR QUAL.fb >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.tsv
: 1394542662:0;zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | cut -f -8 | vcfbiallelic | genoreorder.py | vcf2tsv -n "NA" | tsvsplit CHROM POS REF ALT MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter HWEpval AB DP QA QR PAIRED PAIREDR QUAL.fb >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.tsv &
: 1394542998:0;cat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.tsv | cut -f 5- | prependcol NULL 0 | pv -l | ./tsv2libsvm.py >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input 
: 1394543030:0;svm-scale -r 28_samples.10000per.15param.shuf.25000.train.libsvm.range ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.scale
: 1394543070:0;svm-predict -b 1 ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.scale 28_samples.10000per.15param.shuf.25000.train.libsvm.model ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.predict
: 1394543314:0;zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | cut -f -8 | head -1000 | grep "^#"  >header.vcf
: 1394543645:0;( cat header.vcf; paste <(cat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.tsv | tsvsplit CHROM POS REF ALT | tail -n+2 | awk 'BEGIN { OFS="\t" } { print $1, $2, ".", $3, $4, 0, "." }' ) <(tail -n+2 ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.predict | awk '{ print "SVM1="$2";SVM0="$3 }') ) | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.predict.svm.vcf.gz

: 1394543996:0;zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | cut -f -8 | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz
: 1394544221:0;zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz | vcfintersect -M SVM1 -T SVM1 -i ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz -r ~/human_g1k_v37.fasta | less -S 

: 1394544011:0;zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.vcf.gz | cut -f -8 | genoreorder.py | vcf2tsv -n "NA" | tsvsplit CHROM POS REF ALT MEANPOST MINPOST FIC MQM MQMR AFmle EntropyCenter HWEpval AB DP QA QR PAIRED PAIREDR QUAL.fb >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.tsv
: 1394544257:0;cat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.tsv | cut -f 5- | prependcol NULL 0 | pv -l | ./tsv2libsvm.py >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all  
: 1394544310:0;svm-scale -r 28_samples.10000per.15param.shuf.25000.train.libsvm.range ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all >ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.scale
: 1394544347:0;svm-predict -b 1 ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.scale 28_samples.10000per.15param.shuf.25000.train.libsvm.model ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict

: 1394544690:0;( cat header.vcf; paste <(cat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.input.all.tsv | tsvsplit CHROM POS REF ALT | tail -n+2 | awk 'BEGIN { OFS="\t" } { print $1, $2, ".", $3, $4, 0, "." }' ) <(tail -n+2 ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict | awk '{ print "SVM1="$2";SVM0="$3 }') ) | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict.svm.vcf.gz &
: 1394544770:0;zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz | vcfintersect -M SVM1 -T SVM1 -i ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict.svm.vcf.gz -r ~/human_g1k_v37.fasta | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.svm.vcf.gz &

: 1394544874:0;zcat ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.vcf.gz | vcfintersect -M SVM1 -T SVM1 -i ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.libsvm.all.predict.svm.vcf.gz -r ~/human_g1k_v37.fasta | sed "s/ID=SVM1,Number=A,Type=String,Description=/ID=SVM1,Number=A,Type=Float,Description=/" | bgziptabix ALL.chr20.MVNCall.non_biallelic_snps.annotated.v3.sites.svm.vcf.gz &


