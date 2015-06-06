#!/usr/bin/python
#
# generate yoda files with scatter plots with efficiencies for a few
# observables for a given MC genertor. Do one scatter plot per
# separation measure
#
# Usage:
#
#   produce-alphadependence-data.py  generator output_file
#


import sys,re,yoda,os

if len(sys.argv) != 3:
    sys.exit("Usage: produce-alphadependence-data.py generator output_file")

# open the files
gen = sys.argv[1]

measures=["grej20", "grej50", "qrej20", "qrej50", "srej", "I", "I2"]
observables=["GA_00_00", "GA_20_00", "GA_10_05", "GA_10_10", "GA_10_20"]

scatters=[]
for measure in measures:
    for observable in observables:
        separation_scatter = yoda.Scatter2D(title=measure, path="/separation/"+measure+"_"+observable)
        for flag,value in zip(["-alphax08","","-alphax12"],[0.8,1.0,1.2]):
            command="./get-separation.sh "+gen+"/results/sum-200"+flag+".ioda "+observable+"_R06 "+measure
            separation_scatter.addPoint(value, float(os.popen(command).read().rstrip()), xerrs=0.1)
        scatters.append(separation_scatter)

yoda.write(scatters,sys.argv[2])

