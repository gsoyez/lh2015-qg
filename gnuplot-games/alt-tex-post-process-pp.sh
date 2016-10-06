#!/bin/bash
#
# moves relevant plots into tex/figures directory
#

texfigdir="../tex_jhep/figures/"

cp distributions-dijet-pp-mMDT.pdf   $texfigdir/fig_GA_10_05_R6_pp_mMDT_dijet.pdf
cp distributions-dijet-pp-plain.pdf  $texfigdir/fig_GA_10_05_R6_pp_plain_dijet.pdf
cp distributions-zjet-pp-mMDT.pdf    $texfigdir/fig_GA_10_05_R6_pp_mMDT_zjet.pdf
cp distributions-zjet-pp-plain.pdf   $texfigdir/fig_GA_10_05_R6_pp_plain_zjet.pdf
cp distributions-sep-pp-mMDT.pdf     $texfigdir/fig_GA_10_05_R6_pp_mMDT_separation.pdf
cp distributions-sep-pp-plain.pdf    $texfigdir/fig_GA_10_05_R6_pp_plain_separation.pdf

cp sep-v-ang-pp-mMDT.pdf          $texfigdir/fig_I2_R6_pp_mMDT__all.pdf
cp sep-v-ang-pp-plain.pdf         $texfigdir/fig_I2_R6_pp_plain__all.pdf

cp variations-Q-pp-mMDT.pdf       $texfigdir/fig_I2_GA_10_05_pp_mMDT_Qdep.pdf
cp variations-Q-pp-plain.pdf      $texfigdir/fig_I2_GA_10_05_pp_plain_Qdep.pdf
cp variations-R-pp-mMDT.pdf       $texfigdir/fig_I2_GA_10_05_pp_mMDT_Rdep.pdf
cp variations-R-pp-plain.pdf      $texfigdir/fig_I2_GA_10_05_pp_plain_Rdep.pdf