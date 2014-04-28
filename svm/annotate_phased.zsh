#!/bin/zsh
#
if [ $# -eq 0 ]; then; cat $0; exit; fi

phased_gts=$1
original_gls=$2
reference=$3
region=$4

tabix -h $phased_gts $region \
    | sed "s/\s*$//" \
    | vcfkeepgeno - GT AVGPOST \
    | grep -v PL \
    | vcffixup - \
    | vcflength \
    | sed s/AC=/AC.pop=/ \
    | sed s/AF=/AF.pop=/ \
    | sed s/=AC/=AC.pop/ \
    | sed s/=AF/=AF.pop/ \
    | vcfentropy -w 10 -f $reference \
    | vcfsample2info -f AVGPOST -i MEANPOST \
    | vcfsample2info -f AVGPOST -i MEDIANPOST -m \
    | vcfsample2info -f AVGPOST -i MINPOST -n \
    | vcfaddinfo - <(tabix -h $original_gls $region | vcfqual2info QUAL.fb | arfer | cut -f -8 ) \
    | vt normalize -r ~/human_g1k_v37.fasta - 2>/dev/null
