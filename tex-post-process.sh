#!/bin/bash
#
# moves relevant plots into tex/figures directory
#

texfigdir="tex/figures"

cp plots/uu-200-R06-allMCs-hadron/MC_LHQG_EE/GA_10_05_R6.pdf  $texfigdir/GA_10_05_R6_hadron_quark.pdf
cp plots/gg-200-R06-allMCs-hadron/MC_LHQG_EE/GA_10_05_R6.pdf  $texfigdir/GA_10_05_R6_hadron_gluon.pdf
cp plots/sep-200-R06-allMCs-hadron/MC_LHQG_EE/GA_10_05_R6.pdf $texfigdir/GA_10_05_R6_hadron_separation.pdf
cp plots/sum-200-R06-allMCs-hadron/separation/I2_R6.pdf       $texfigdir/I2_R6_hadron__all.pdf

cp plots/sum-200-R06-Pythia-8205-hadron/separation/I2_R6.pdf  $texfigdir/I2_R6_hadron_pythia.pdf
cp plots/sum-200-R06-Sherpa-2.1.1-hadron/separation/I2_R6.pdf $texfigdir/I2_R6_hadron_sherpa.pdf
cp plots/sum-200-R06-Vincia-1201-hadron/separation/I2_R6.pdf  $texfigdir/I2_R6_hadron_vincia.pdf
cp plots/sum-200-R06-Herwig-2_7_1-hadron/separation/I2_R6.pdf $texfigdir/I2_R6_hadron_herwig.pdf

cp plots/sum-200-R06-Pythia-8205-parton/separation/I2_R6.pdf  $texfigdir/I2_R6_parton_pythia.pdf
cp plots/sum-200-R06-Sherpa-2.1.1-parton/separation/I2_R6.pdf $texfigdir/I2_R6_parton_sherpa.pdf
cp plots/sum-200-R06-Vincia-1201-parton/separation/I2_R6.pdf  $texfigdir/I2_R6_parton_vincia.pdf
cp plots/sum-200-R06-Herwig-2_7_1-parton/separation/I2_R6.pdf $texfigdir/I2_R6_parton_herwig.pdf

cp plots/modulations-hadron/Qdependence/I2_GA_10_05.pdf      $texfigdir/I2_GA_10_05_hadron_Qdep.pdf
cp plots/modulations-hadron/Rdependence/I2_GA_10_05.pdf      $texfigdir/I2_GA_10_05_hadron_Rdep.pdf
cp plots/modulations-hadron/alphasdependence/I2_GA_10_05.pdf $texfigdir/I2_GA_10_05_hadron_alphadep.pdf

cp plots/modulations-parton/Qdependence/I2_GA_10_05.pdf      $texfigdir/I2_GA_10_05_parton_Qdep.pdf
cp plots/modulations-parton/Rdependence/I2_GA_10_05.pdf      $texfigdir/I2_GA_10_05_parton_Rdep.pdf
cp plots/modulations-parton/alphasdependence/I2_GA_10_05.pdf $texfigdir/I2_GA_10_05_parton_alphadep.pdf

