#!/bin/zsh

sed s/NUMALT/NUMALT.prefilter/ | vcfnumalt - | vcffilter -f "! ( NUMALT = NUMALT.prefilter )" 
