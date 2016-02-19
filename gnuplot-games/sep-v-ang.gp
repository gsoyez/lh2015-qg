# plot the separation as a function of the shape for the MC baselines
#
# each page of the plot corresponds to a different separation measure

call 'common.gp'

#----------------------------------------------------------------------
# the list of quality measures and teh associated labels
measures="I2 I qrej20 qrej50 grej20 grej50 srej"
mlabs='I@"_{1/2} I_{1/2} q@_{50}^{rej} g@_{20}^{rej} g@_{50}^{rej} s^{rej}'

ymins="0.0 0.0 0.85 0.75 0.85 0.75 0.6"
ymaxs="0.4 0.3 1.00 1.00 1.00 1.00 0.8"

# the shapes (we made sure that LHA was first, it might be more
# convenient to keep the ordering the same as when we plot things with
# the shape as x-axis)
set xtics ("(0,0)" 0, "(2,0)" 1, "(1,1/2)" 2, "(1,1)" 3, "(1,2)" 4)
set xlabel 'observable ({/Symbol k},{/Symbol l})'
set xrange [-0.5:7.0]

# extract a given distribution from a given file
sep(measure,generator,level)=yodaget(sprintf("separation/%s",measure), '../'.generator.'/'.level.'/sum-200.yoda')

#----------------------------------------------------------------------
# now really plot things

set key at graph 0.99,0.96

# loop over parton and hadron levels
do for [level in "parton hadron"]{
    gens=generators(level)

    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'sep-v-ang-'.level.'.pdf'
    set title level.', Q=200 GeV, R=0.6'

    do for [imeas=1:words(measures)]{
        set ylabel 'separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        plot for [gen in gens] sep(word(measures,imeas),gen,level) u (0.5*($1+$2)):3:(0.5*($2-$1)) t escape(gen) w xerr
    }
}

set out
