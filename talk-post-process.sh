#!/bin/bash
#
# moves Jesse's favorite plots into their own directory
#

talkdir="JesseTalk"
# Create diretory if necessary
if [ ! -d $talkdir ]; then
mkdir $talkdir
fi

mkdir $talkdir/1-LHAQ-best
mkdir $talkdir/2-LHAG-best
mkdir $talkdir/3-LHAsep-best
mkdir $talkdir/4-Summary
mkdir $talkdir/5-Pythia-8205
mkdir $talkdir/6-Sherpa-2.1.1
mkdir $talkdir/7-Vincia-1201
mkdir $talkdir/8-Herwig-2_7_1
mkdir $talkdir/9-Qdep
mkdir $talkdir/10-Rdep
mkdir $talkdir/11-alphadep

cp plots/uu-200-R06-allMCs/MC_LHQG_EE/GA_10_05_R6.pdf $talkdir/1-LHAQ-best
cp plots/gg-200-R06-allMCs/MC_LHQG_EE/GA_10_05_R6.pdf $talkdir/2-LHAG-best
cp plots/sep-200-R06-allMCs/MC_LHQG_EE/GA_10_05_R6.pdf $talkdir/3-LHAsep-best
cp plots/sum-200-R06-allMCs/separation/I2_R6.pdf $talkdir/4-Summary

cp plots/sum-200-R06-Pythia-8205/separation/I2_R6.pdf $talkdir/5-Pythia-8205
cp plots/sum-200-R06-Sherpa-2.1.1/separation/I2_R6.pdf $talkdir/6-Sherpa-2.1.1
cp plots/sum-200-R06-Vincia-1201/separation/I2_R6.pdf $talkdir/7-Vincia-1201
cp plots/sum-200-R06-Herwig-2_7_1/separation/I2_R6.pdf $talkdir/8-Herwig-2_7_1

cp plots/modulations/Qdependence/I2_GA_10_05.pdf $talkdir/9-Qdep
cp plots/modulations/Rdependence/I2_GA_10_05.pdf $talkdir/10-Rdep
cp plots/modulations/alphasdependence/I2_GA_10_05.pdf $talkdir/11-alphadep

