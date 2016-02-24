# plot the separation as a function of the shape for the MC baselines
#
# each page of the plot corresponds to a different separation measure

call 'common.gp'

#----------------------------------------------------------------------
# the list of quality measures and teh associated labels
measures="I2 I qrej20 qrej50 grej20 grej50 srej"
mlabs='"{/Symbol D}" I_{1/2} q@_{20}^{rej} q@_{50}^{rej} g@_{20}^{rej} g@_{50}^{rej} s^{rej}'


# the different levels of distributions we shall plot
levels="Parton-level Hadron-level"
leveltags="parton hadron"

ymins="0.0  0.0 0.9 0.72 0.9 0.72 0.6"
ymaxs="0.45 0.3 1.0 1.00 1.0 1.00 0.8"

# the shapes (we made sure that LHA was first, it might be more
# convenient to keep the ordering the same as when we plot things with
# the shape as x-axis)
set xtics ("(0,0)" 0, "(2,0)" 1, "(1,0.5)" 2, "(1,1)" 3, "(1,2)" 4)
set xlabel 'Angularity: ({/Symbol k},{/Symbol b})'
set xrange [-0.5:7.0]

# extract a given distribution from a given file
sep(measure,generator,leveltag)=yodaget(sprintf("separation/%s_",measure), '../'.generator.'/'.leveltag.'/sum-200.yoda')

#----------------------------------------------------------------------
# now really plot things

set key at graph 0.99,0.96

#set label 1 '{/*0.9 Q=200 GeV}' left at graph 0.75,0.38
#set label 2 '{/*0.9 R=0.6}'     left at graph 0.75,0.32

set label 1 '{/*0.9 Q=200 GeV}' right at graph 0.95,0.48
set label 2 '{/*0.9 R=0.6}'     right at graph 0.95,0.42

# loop over parton and hadron levels
do for [jtype=1:words(levels)]{
    level=word(levels,jtype)
    leveltag=word(leveltags,jtype) 
    gens=generators(leveltag)
    gtags=gentags(leveltag)
    print "  ".level
    
    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'sep-v-ang-'.leveltag.'.pdf'
    set title '{/:Bold '.level.'} {/: }'

    do for [imeas=1:words(measures)]{
        set ylabel 'Separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        plot for [igen=1:words(gens)] sep(word(measures,imeas),word(gens,igen),leveltag) u (0.5*($1+$2)):3:(0.5*($2-$1)) t word(gtags,igen) w xerr
    }
}

set out
