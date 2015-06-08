#!/bin/bash
#
# moves Jesse's favorite plots into their own directory
#

talkdir="JesseTalk"
# Create diretory if necessary
if [ ! -d $talkdir ]; then
  mkdir $talkdir
fi

mkdir $talkdir/LHAQ-best
mkdir $talkdir/LHAG-best
mkdir $talkdir/LHAsep-best 
cp plots/uu-200-R06-allMCs/MC_LHQG_EE/GA_10_05_R6.* $talkdir/LHAQ-best
cp plots/gg-200-R06-allMCs/MC_LHQG_EE/GA_10_05_R6.* $talkdir/LHAG-best
cp plots/sep-200-R06-allMCs/MC_LHQG_EE/GA_10_05_R6.* $talkdir/LHAsep-best
