#!/bin/bash
#
# moves relevant plots into tex/figures directory
#

texfigdir="../tex_jhep/figures/"

cp distributions-uu-hadron.pdf  $texfigdir/fig_GA_10_05_R6_hadron_quark.pdf
cp distributions-gg-hadron.pdf  $texfigdir/fig_GA_10_05_R6_hadron_gluon.pdf
cp distributions-sep-hadron.pdf $texfigdir/fig_GA_10_05_R6_hadron_separation.pdf
cp sep-v-ang-hadron.pdf         $texfigdir/fig_I2_R6_hadron__all.pdf


cp distributions-uu-parton.pdf  $texfigdir/fig_GA_10_05_R6_parton_quark.pdf
cp distributions-gg-parton.pdf  $texfigdir/fig_GA_10_05_R6_parton_gluon.pdf
cp distributions-sep-parton.pdf $texfigdir/fig_GA_10_05_R6_parton_separation.pdf
cp sep-v-ang-parton.pdf         $texfigdir/fig_I2_R6_parton__all.pdf


cp sep-v-ang-Pythia-8205-hadron.pdf  $texfigdir/fig_I2_R6_hadron_pythia.pdf
cp sep-v-ang-Sherpa-2.1.1-hadron.pdf $texfigdir/fig_I2_R6_hadron_sherpa.pdf
cp sep-v-ang-Vincia-1201-hadron.pdf  $texfigdir/fig_I2_R6_hadron_vincia.pdf
cp sep-v-ang-Herwig-2_7_1-hadron.pdf $texfigdir/fig_I2_R6_hadron_herwig.pdf
cp sep-v-ang-Ariadne-hadron.pdf      $texfigdir/fig_I2_R6_hadron_ariadne.pdf
cp sep-v-ang-Dire-1.0.0-hadron.pdf   $texfigdir/fig_I2_R6_hadron_dire.pdf
cp sep-v-ang-AnalyticResum-hadron.pdf      $texfigdir/fig_I2_R6_hadron_analytic.pdf

cp sep-v-ang-Pythia-8205-parton.pdf  $texfigdir/fig_I2_R6_parton_pythia.pdf
cp sep-v-ang-Sherpa-2.1.1-parton.pdf $texfigdir/fig_I2_R6_parton_sherpa.pdf
cp sep-v-ang-Vincia-1201-parton.pdf  $texfigdir/fig_I2_R6_parton_vincia.pdf
cp sep-v-ang-Herwig-2_7_1-parton.pdf $texfigdir/fig_I2_R6_parton_herwig.pdf
cp sep-v-ang-Ariadne-parton.pdf      $texfigdir/fig_I2_R6_parton_aridane.pdf
cp sep-v-ang-Dire-1.0.0-parton.pdf   $texfigdir/fig_I2_R6_parton_dire.pdf
cp sep-v-ang-AnalyticResum-parton.pdf      $texfigdir/fig_I2_R6_parton_analytic.pdf

cp variations-Q-hadron.pdf      $texfigdir/fig_I2_GA_10_05_hadron_Qdep.pdf
cp variations-R-hadron.pdf      $texfigdir/fig_I2_GA_10_05_hadron_Rdep.pdf
cp variations-alphas-hadron.pdf $texfigdir/fig_I2_GA_10_05_hadron_alphadep.pdf

cp variations-Q-parton.pdf      $texfigdir/fig_I2_GA_10_05_parton_Qdep.pdf
cp variations-R-parton.pdf      $texfigdir/fig_I2_GA_10_05_parton_Rdep.pdf
cp variations-alphas-parton.pdf $texfigdir/fig_I2_GA_10_05_parton_alphadep.pdf

