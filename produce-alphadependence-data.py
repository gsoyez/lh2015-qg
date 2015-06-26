#!/usr/bin/env python
#
# generate yoda files with scatter plots with efficiencies for a few
# observables for a given MC genertor. Do one scatter plot per
# separation measure
#
# Usage:
#
#   produce-alphadependence-data.py  generator level output_file
#


import sys,re,yoda,os

if len(sys.argv) != 4:
    sys.exit("Usage: produce-alphadependence-data.py generator level output_file")

# open the files
gen = sys.argv[1]
level = sys.argv[2]

measures=["grej20", "grej50", "qrej20", "qrej50", "srej", "I", "I2"]
observables=["GA_00_00", "GA_20_00", "GA_10_05", "GA_10_10", "GA_10_20"]

scatters=[]
for measure in measures:
    for observable in observables:
        separation_scatter = yoda.Scatter2D(title=measure, path="/alphasdependence/"+measure+"_"+observable)
        for flag,value in zip(["-alphasx08","-alphasx09","","-alphasx11","-alphasx12"],[0.8,0.9,1.0,1.1,1.2]):
            command="./get-separation.sh "+gen+"/"+level+"/sep-200"+flag+".log "+observable+"_R6 "+measure
            separation_scatter.addPoint(value, float(os.popen(command).read().rstrip()), xerrs=0.05)
        scatters.append(separation_scatter)

yoda.write(scatters,sys.argv[3])

