#!/bin/zsh

region=$1
samheader=$2
bamlist=$3
samtools merge -u -R $region -h $samheader - $(cat $bamlist | tr '\n' ' ')
