#!/usr/bin/env python
#
# For R=0.6 and beta=0.5,1,2, get the R dependence of the average (and
# dispersion) of the angularity distribution
#
# The arguments are the generator and the level
# It will produce info for both the uu and the gg channel
#
# Usage:
#
#   produce-Qdependence-avg.py  generator level output_file
#


import sys,re,yoda,os,math

if len(sys.argv) != 4:
    sys.exit("Usage: produce-Qdependence-avg.py generator level output_file")

# open the files
gen = sys.argv[1]
level = sys.argv[2]

observables=["GA_10_05_R6", "GA_10_10_R6", "GA_10_20_R6"]
flavours=["uu", "gg"]

scatters=[]
for flavour in flavours:
    for observable in observables:
        separation_scatter = yoda.Scatter2D(title=observable, path="/Qdependence/"+flavour+"_"+observable)
        for Q in [50,100,200,400,800]:
            hname="/MC_LHQG_EE/"+observable
            dict_all=yoda.read(gen+"/"+level+"/"+flavour+"-"+str(Q)+".yoda", True, hname)
            Qmin=Q/math.sqrt(2.0)
            Qmax=Q*math.sqrt(2.0)
            separation_scatter.addPoint(Q, dict_all[hname].xMean(), xerrs=[Q-Qmin,Qmax-Q])
            # add that for stddev as errorbars: , yerrs=dict_all[hname].xStdDev())
        scatters.append(separation_scatter)

yoda.write(scatters,sys.argv[3])

