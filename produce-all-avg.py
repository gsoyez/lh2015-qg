#!/usr/bin/env python
#
# For all Q, R and beta, get the average (and dispersion) of the
# angularity distribution
#
# This is repeated for uu and gg files, then for parton and hadrons
#
# The arguments are the generator and the level
# It will produce info for both the uu and the gg channel
#
# Usage:
#
#   produce-all-avg.py  generator
#


import sys,re,yoda,os,math

if len(sys.argv) != 2:
    sys.exit("Usage: produce-all-avg.py generator")

# open the files
gen = sys.argv[1]

flavours=["uu", "gg"]
bvalues=["05","10","20"]
#=["GA_10_05_R", "GA_10_10_R", "GA_10_20_R"]
Rvalues=[2,4, 6, 8,10]
Qvalues=[50,100,200,400,800]

levels=["parton","hadron"]
flavours=["uu","gg"]

print "#columns: Q R beta avg_uu_parton avg_gg_parton avg_uu_hadron avg_gg_hadron"
for Q in Qvalues:
    for R in Rvalues:
        for beta in bvalues:
            hname="/MC_LHQG_EE/GA_10_"+str(beta)+"_R"+str(R)
            print Q,0.1*R,0.1*float(beta),
            for level in levels:
                for flavour in flavours:
                    dict_all=yoda.read(gen+"/"+level+"/"+flavour+"-"+str(Q)+".yoda", True)
                    print dict_all[hname].xMean(),
            print
            
            


