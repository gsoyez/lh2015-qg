# plot the separation as a function of the shape for the MC baselines
#
# each page of the plot corresponds to a different separation measure

call 'common-pp.gp'

#----------------------------------------------------------------------
# the different levels of distributions we shall plot
# only supprt hadron level here
level="Hadron-level"
leveltag="hadron"

# do plain jet and mmdt
modes='plain mMDT'
modetags='"" "mMDT_"'

pTmin=100 # note that this is hardcoded in produce-separation-data.py
R=0.4

# the shapes (we made sure that LHA was first, it might be more
# convenient to keep the ordering the same as when we plot things with
# the shape as x-axis)
set xtics ("(0,0)" 0, "(2,0)" 1, "(1,0.5)" 2, "(1,1)" 3, "(1,2)" 4)
set xlabel 'Angularity: ({/Symbol k},{/Symbol b})'
set xrange [-0.5:7.6]

# extract a given distribution from a given file
sep(measure,generator,modetag)=yodaget(sprintf("separation/%s%s_R%d",modetag,measure,10*R), '../'.generator.'/lhc/'.leveltag.'/sum.yoda')

#----------------------------------------------------------------------
# now really plot things

set key at graph 0.99,0.96

set label 1 sprintf('{/*0.9 p@_T^{min}=%d GeV}',pTmin) right at graph 0.95,0.48
set label 2 sprintf('{/*0.9 R=%g}',R)                  right at graph 0.95,0.42

# loop over parton and hadron levels
do for [jtype=1:words(modes)]{
    mode=word(modes, jtype)
    modetag=word(modetags, jtype)
    
    gens=generators(leveltag)
    gtags=gentags(leveltag)
    print "  ".mode
    
    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'sep-v-ang-pp-'.mode.'.pdf'
    set title '{/:Bold '.level.', '.mode.' jet} {/: }'

    do for [imeas=1:words(measures)]{
        set ylabel 'Separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        plot for [igen=1:words(gens)] sep(word(measures,imeas),word(gens,igen),modetag) u (0.5*($1+$2)):3:(0.5*($2-$1)) t word(gtags,igen) w xerr
    }
}

set out
