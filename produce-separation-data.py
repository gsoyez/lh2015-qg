#!/usr/bin/python
#
# generate yoda files with scatter plots with efficiencies for a few
# observables for a given MC genertor. Do one scatter plot per
# separation measure
#
# Usage:
#
#   produce-separation-files.py  separation_table
#


import sys,re,yoda,os

if len(sys.argv) != 3:
    sys.exit("Usage: produce-separation-files.py  separation_table")

# open the files
table = sys.argv[1]

measures=["grej20", "grej50", "qrej20", "qrej50", "srej", "I", "I2"]
Rvalues=["R3","R6","R9"]
observables=["GA_00_00", "GA_20_00", "GA_10_05", "GA_10_10", "GA_10_20"]

scatters=[]
for measure in measures:
    for Rval in Rvalues:
        separation_scatter = yoda.Scatter2D(title=measure, path="/separation/"+measure+"_"+Rval)
        for observable,index in zip(observables,range(0,len(observables))):
            command="./get-separation.sh "+table+" "+observable+"_"+Rval+" "+measure
            separation_scatter.addPoint(index, float(os.popen(command).read().rstrip()), xerrs=0.5)
        scatters.append(separation_scatter)


yoda.write(scatters,sys.argv[2])

