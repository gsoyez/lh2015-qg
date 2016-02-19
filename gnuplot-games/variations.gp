# plot quark, gluon and separation distributions comparing the
# generators (each page of the pdf corresponds to a different
# generalised angularity)

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
kappas="1   1 1 0 2"
betas ="0.5 1 2 0 0"

# extract a given distribution from a given file
sep(var,varin,measure,kappa,beta,generator,level)=yodaget(sprintf("%sdependence/%s_GA_%02d_%02d",varin,measure,10*kappa,10*beta), '../modulations/'.var.'dep-'.generator.'-'.level.'.yoda')

#----------------------------------------------------------------------
# now really plot things

set key at graph 0.99,0.04 bottom right

#----------------------------------------------------------------------
# Q variation
# loop over parton and hadron levels
set xlabel 'Q [GeV]'
set xrange [30:9990]
set log x
do for [level in "parton hadron"]{
    gens=generators(level)

    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'variations-Q-'.level.'.pdf'

    do for [imeas=1:words(measures)]{
        set ylabel 'separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas,iang)
            set title '{/Symbol l}('.kappa.','.beta.'),'. level.', R=0.6'

            plot for [gen in gens] sep("Q","Q",word(measures,imeas),kappa,beta,gen,level) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t escape(gen) w xerr
        }
    }
}


#----------------------------------------------------------------------
# alphas variation
# loop over parton and hadron levels
set xlabel '{/Symbol a}_s/{/Symbol a}@_s^{(default)}'
unset log x
set xrange [0.7:1.6]
set xtics (0.8, 0.9, 1.0, 1.1, 1.2)
do for [level in "parton hadron"]{
    gens=generators(level)

    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'variations-alphas-'.level.'.pdf'

    do for [imeas=1:words(measures)]{
        set ylabel 'separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas,iang)
            set title '{/Symbol l}('.kappa.','.beta.'),'. level.', Q=200 GeV, R=0.6'

            plot for [gen in gens] sep("alpha","alphas",word(measures,imeas),kappa,beta,gen,level) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t escape(gen) w xerr
        }
    }
}


#----------------------------------------------------------------------
# R variation
# loop over parton and hadron levels
set xlabel 'R'
set xrange [0.0:1.7]
set xtics 0.2
do for [level in "parton hadron"]{
    gens=generators(level)

    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'variations-R-'.level.'.pdf'

    do for [imeas=1:words(measures)]{
        set ylabel 'separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas,iang)
            set title '{/Symbol l}('.kappa.','.beta.'),'. level.', Q=200 GeV'

            plot for [gen in gens] sep("R","R",word(measures,imeas),kappa,beta,gen,level) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t escape(gen) w xerr
        }
    }
}



set out
