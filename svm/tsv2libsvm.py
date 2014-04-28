#!/usr/bin/python

import sys

header = sys.stdin.readline().strip().split("\t")
#print header

# assume that the first field is the class label
# if we see NA or '.' in the input, that means "no value"

for line in sys.stdin:
    line = line.strip().split("\t")
    i = 1
    converted = [line[0]]
    for field in line[1:]:
        if field != "NA" and field != ".":
            field = str(i) + ":" + field
            converted.append(field)
        i += 1
    print " ".join(converted)
