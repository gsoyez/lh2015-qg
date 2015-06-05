#!/usr/bin/env python

import yoda,sys,re

if len(sys.argv) != 3:
    sys.exit("Usage: yoda-rebin.py input.yoda output.yoda")

all_aos = yoda.readYODA(sys.argv[1])

for ao in all_aos.itervalues():
    # we want to rebin anything except multiplicity
    pattern = re.compile(".*GA_00_00.*|.*Mult.*")

    if not pattern.match(ao.path):
        ao.rebin(5)

yoda.writeYODA(all_aos,sys.argv[2])
