#!/usr/bin/python
#
# generate yoda files with scatter plots with efficiencies for a few
# observables for a given MC genertor. Do one scatter plot per
# separation measure
#
# Usage:
#
#   produce-Qdependence-data.py  generator output_file
#


import sys,re,yoda,os,math

if len(sys.argv) != 3:
    sys.exit("Usage: produce-Qdependence-data.py generator output_file")

# open the files
gen = sys.argv[1]

measures=["grej20", "grej50", "qrej20", "qrej50", "srej", "I", "I2"]
observables=["GA_00_00", "GA_20_00", "GA_10_05", "GA_10_10", "GA_10_20"]

scatters=[]
for measure in measures:
    for observable in observables:
        separation_scatter = yoda.Scatter2D(title=measure, path="/Qdependence/"+measure+"_"+observable)
        for Q in [50,100,200,400,800]:
            command="./get-separation.sh "+gen+"/results/sep-"+str(Q)+".log "+observable+"_R6 "+measure
            Qmin=Q/math.sqrt(2.0)
            Qmax=Q*math.sqrt(2.0)
            separation_scatter.addPoint(Q, float(os.popen(command).read().rstrip()), xerrs=[Q-Qmin,Qmax-Q])
        scatters.append(separation_scatter)

yoda.write(scatters,sys.argv[2])

