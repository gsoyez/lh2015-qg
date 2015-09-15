#!/usr/bin/env python
#
# export Jesse's 2-column format (x-y) into a yoda scatter plot.  It
# also merges mutiple beta and R valeus in a single yoda file in order
# to reach the same format as the output of the MC_QG_EE Rivet
# analysis.
#
# Usage:
#
#   txt2yoda input_basename
#
# where th basename includes the event level (parton or hadron), the
# parton type (uu or gg), an optional flag and the Q. Examples:
#   parton/uu-200
#   hadron/gg-nogqq-50

import sys,re,yoda,os

if len(sys.argv) != 2:
    sys.exit("Usage: txt2yoda.py input_basename\nExample basename parton/uu-nogqq")

# filename info
base = sys.argv[1]
output_filename = base+".yoda"

# the R and beta values we shall loop over
Rvalues=["02", "04", "06", "08", "10"]
betas=["05", "10", "20"]

# an array for all the scatter plots
yoda_histograms=[]

# loop over the beta and R values
for beta in betas:
    for Rval in Rvalues:
        # construct the input filename and open it
        input_filename  = base+"-beta"+beta+"-R"+Rval+".txt"
        f = open(input_filename, 'r')

        # declare the yoda 2D scatter
        yoda_histo = yoda.Histo1D(500, 0.0, 1.0, path="/MC_LHQG_EE/GA_10_"+beta+"_R"+str(int(Rval)))

        # parse the input file and construct the scatter plot
        for line in f:
            tokens=line.split()
            yoda_histo.fill((float(tokens[0]) + float(tokens[1]))/2.0, float(tokens[2])*(float(tokens[1])-float(tokens[0])))

        yoda_histograms.append(yoda_histo)

yoda.write(yoda_histograms, output_filename)
