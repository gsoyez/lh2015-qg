#!/usr/bin/env python
#
# export Jesse's 2-column format (x-y) into a yoda scatter plot

import sys,re,yoda,os

if len(sys.argv) != 3:
    sys.exit("Usage: txt2yoda.py input_txt_file output_yoda_file")

# open the files
input_filename  = sys.argv[1]
output_filename = sys.argv[2]

f = open(input_filename, 'r')
yoda_scatter = yoda.Scatter2D(title="my_distribution", path="/MC_LHQG_EE/GA_00_00_R10")

for line in f:
    tokens=line.split()
    yoda_scatter.addPoint((float(tokens[0]) + float(tokens[1]))/2.0, float(tokens[2]), xerrs=(float(tokens[1]) - float(tokens[0]))/2.0)

yoda.write(yoda_scatter, output_filename)
