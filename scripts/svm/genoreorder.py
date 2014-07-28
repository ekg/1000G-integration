#!/usr/bin/python

import sys
import re

m=re.compile("(.)[\|\/](.)")

for line in sys.stdin:
    r = m.search(line)
    while r:
        n = "/".join(sorted(r.groups()))
        line = line[:r.start()] + n + line[r.end():]
        r = m.search(line, r.end())
    sys.stdout.write(line)
    sys.stdout.flush()
