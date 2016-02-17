# some generic tools and common style
#
# It also provides some initialisation for te plots, so please call
# this file at the start of each "plotting" gnuplot file

reset

# extract a histogram from a yoda file
yodaget(name, file)='< yoda2flat -m "/'.name.'" '.file.' - | grep -v -E "^[PSTXY]"'

# generators
generators(level)= (level eq "parton") \
  ? "Pythia-8205 Sherpa-2.1.1 Vincia-1201 Herwig-2_7_1 Deductor-1.0.2" \
  : "Pythia-8205 Sherpa-2.1.1 Vincia-1201 Herwig-2_7_1"

# line styles
# set style line 1 lt 1 dt 1 lc rgb "#ff0000" lw 3  # Pythia
# set style line 2 lt 1 dt 2 lc rgb "#66ff66" lw 3  # Sherpa
# set style line 3 lt 1 dt 1 lc rgb "#0000ff" lw 3  # Vincia
# set style line 4 lt 1 dt 2 lc rgb "#000000" lw 3  # Herwig
# set style line 5 lt 1 dt 4 lc rgb "#888888" lw 3  # Deductor

set style line 1 lt 1 dt 1       lc rgb "#8888ff" lw 3  # Pythia
set style line 2 lt 1 dt (12,12) lc rgb "#0000ff" lw 3  # Sherpa
set style line 3 lt 1 dt 1       lc rgb "#ff8888" lw 3  # Vincia
set style line 4 lt 1 dt (12,12) lc rgb "#ff0000" lw 3  # Herwig
set style line 5 lt 1 dt (2,4)   lc rgb "#000000" lw 3  # Deductor

set style increment user

# make sure all the plots have a common look/ratio
set term pdfcairo enhanced color fontscale 1 size 15cm,13cm

# a dirty trick to escape "_" in gnuplot labels
escape(label)=system('echo "'.label.'" | sed "s/_/\\\\_/g"')
