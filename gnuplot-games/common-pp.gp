# some generic tools and common style
#
# It also provides some initialisation for te plots, so please call
# this file at the start of each "plotting" gnuplot file

reset

# extract a histogram from a yoda file
yodaget(name, file)='< yoda2flat -m "/'.name.'" '.file.' - | grep -v -E "^[PSTXY]"'

# generators
#generators(level)= "Pythia-8215 Vincia-2001"
#generators(level)= "Pythia-8215 Herwig-7.0.3 Vincia-2001"
generators(level)= "Pythia-8215 Herwig-2_7_1 Sherpa-2.2.1 Vincia-2001"


#gentags(level)='"Pythia {/*0.8 8.215}" "Vincia {/*0.8 2.001}" '
gentags(level)='"Pythia {/*0.8 8.215}" "Herwig {/*0.8 2.7.1}" "Sherpa {/*0.8 2.2.1}" "Vincia {/*0.8 2.001}" '

# line styles (currently adapted so that Vincia matched with te ee Vincia)

set style line 1 lt 1 dt (24,0)            lc rgb "#444444" lw 4 ps 0.0 # Pythia
set style line 2 lt 1 dt (20,4)            lc rgb "#e41a1c" lw 4 ps 0.0 # Herwig
set style line 3 lt 1 dt (8,4,8,4)         lc rgb "#f07800" lw 4 ps 0.0 # Sherpa
set style line 4 lt 1 dt (14,4,2,4)        lc rgb "#4daf4a" lw 4 ps 0.0 # Vincia
#set style line 3 lt 1 dt (14,4,2,4)        lc rgb "#4daf4a" lw 4 ps 0.0 # Vincia
set style line 5 lt 1 dt (8,4,2,4,2,4)     lc rgb "#377eb8" lw 4 ps 0.0 # Deductor
set style line 6 lt 1 dt (2,4)             lc rgb "#7b3294" lw 4 ps 0.0 # Ariadne
set style line 7 lt 1 dt (4,2)             lc rgb "#8c510a" lw 4 ps 0.0 # Dire
set style line 8 lt 1 dt (1,2)             lc rgb "#000000" lw 4 ps 0.0 # Analytic

set style increment user
set bar small

# make sure all the plots have a common look/ratio
set term pdfcairo enhanced color font "Palatino" fontscale 0.9 size 15cm,13cm

# make sure that the plotting area is the same independently on axes format
set bmargin at screen 0.14
set tmargin at screen 0.93
set lmargin at screen 0.15
set rmargin at screen 0.97
set xlabel '' offset 0,0.4
set title '' offset 0,-0.7

# a dirty trick to escape "_" in gnuplot labels
escape(label)=system('echo "'.label.'" | sed "s/_/\\\\_/g"')

# allow to get rid of all the values which are 0
treat_zero_as_nan(x)=(x==0) ? 1/0 : x

#--------------------------------------------------
# infos for the separation measures

# the list of quality measures and the associated labels
measures="I2 I qrej20 qrej50 grej20 grej50 srej"
mlabs='"{/Symbol D}" I_{1/2} q@_{20}^{rej} q@_{50}^{rej} g@_{20}^{rej} g@_{50}^{rej} s^{rej}'

# the ranges
#
# These should cover most of the cases in the plots. These is a small
# exception for the "grej" ones and ptD but covering these would
# probably impact the other grej plots.
ymins="0.0  0.0  0.8  0.4 0.75 0.4 0.45"
ymaxs="0.15 0.12 1.0  1.0 1.00 1.0 0.7 "


#set label 501 "{/=36 PRELIMINARY}" center at graph 0.5,0.5 rotate by 35 tc "#cccccc"