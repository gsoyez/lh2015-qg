#!/usr/bin/env python
#
# For Q=200 and beta=0.5,1,2, get the R dependence of the average (and
# dispersion) of the angularity distribution
#
# The arguments are the generator and the level
# It will produce info for both the uu and the gg channel
#
# Usage:
#
#   produce-Rdependence-avg.py  generator level output_file
#


import sys,re,yoda,os,math

if len(sys.argv) != 4:
    sys.exit("Usage: produce-Rdependence-avg.py generator level output_file")

# open the files
gen = sys.argv[1]
level = sys.argv[2]

observables=["GA_10_05", "GA_10_10", "GA_10_20"]
flavours=["uu", "gg"]
Rvalues=[2,4, 6, 8,10]

scatters=[]
for flavour in flavours:
    for observable in observables:
        separation_scatter = yoda.Scatter2D(title=observable, path="/Rdependence/"+flavour+"_"+observable)
        hnamebase="/MC_LHQG_EE/"+observable+"_R"
        dict_all=yoda.read(gen+"/"+level+"/"+flavour+"-200.yoda", True, hnamebase)
        for Rval in Rvalues:
            separation_scatter.addPoint(0.1*Rval, dict_all[hnamebase+str(Rval)].xMean(), xerrs=0.1)
            # add that for stddev as errorbars: , yerrs=dict_all[hnamebase+str(Rval)].xStdDev())
        scatters.append(separation_scatter)

yoda.write(scatters,sys.argv[3])
