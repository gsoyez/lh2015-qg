#!/usr/bin/env python
#
# generate yoda files with scatter plots with efficiencies for a few
# observables for a given MC genertor. Do one scatter plot per
# separation measure
#
# Usage:
#
#   produce-Rdependence-data.py  separation_table output_file
#


import sys,re,yoda,os

if len(sys.argv) != 3:
    sys.exit("Usage: produce-Rdependence-data.py  separation_table output_file")

# open the files
table = sys.argv[1]

measures=["grej20", "grej50", "qrej20", "qrej50", "srej", "I", "I2"]
Rvalues=[2,4, 6, 8,10]
observables=["GA_00_00", "GA_20_00", "GA_10_05", "GA_10_10", "GA_10_20"]

scatters=[]
for measure in measures:
    for observable in observables:
        separation_scatter = yoda.Scatter2D(title=measure, path="/Rdependence/"+measure+"_"+observable)
        for Rval in Rvalues:
            command="./get-separation.sh "+table+" "+observable+"_R"+str(Rval)+" "+measure
            separation_scatter.addPoint(0.1*Rval, float(os.popen(command).read().rstrip()), xerrs=0.1)
        scatters.append(separation_scatter)

yoda.write(scatters,sys.argv[2])

