# plot the dependence of the separation as a function of several
# physics parameters: Q, R and the alphas value

call 'common.gp'

#----------------------------------------------------------------------

# the different levels of distributions we shall plot
levels="parton-level hadron-level"
leveltags="parton hadron"

# the shapes (we made sure that LHA was first, it might be more
# convenient to keep the ordering the same as when we plot things with
# the shape as x-axis)
kappas="1   1 1 0 2"
betas ="0.5 1 2 0 0"

# get the label associated with a shape
lambda(kappa,beta)=sprintf("{/Symbol l}@^{%s}_{%s}", kappa, beta)
extrax(kappa,beta)=(beta==0.5 && kappa==1) ? ' [LHA]' : (beta>0) ? '' : (kappa==0) ? ' [multiplicity]' : (kappa==2) ? ' [(p@_T^D)^2]' : ''

# extract a given distribution from a given file
sep(var,varin,measure,kappa,beta,generator,level)=yodaget(sprintf("%sdependence/%s_GA_%02d_%02d",varin,measure,10*kappa,10*beta), '../modulations/'.var.'dep-'.generator.'-'.level.'.yoda')

#----------------------------------------------------------------------
# now really plot things

#set key at graph 0.99,0.04 bottom right
set key at graph 0.99,0.96


#----------------------------------------------------------------------
# Q variation
# loop over parton and hadron levels
set xlabel 'Q [GeV]'
set xrange [30:12000]
set xtics (40 1,50,60 1,70 1,80 1,90 1,100,200,300 1,400 1,500,600 1,700 1,800 1,900 1,1000)
set log x

set label 1 '{/*0.9 R=0.6}'     right at graph 0.95,0.48
set label 2 '{/*0.9 {/Symbol a}_s={/Symbol a}_{s0}}' right at graph 0.95,0.42

# loop over parton and hadron levels
do for [jtype=1:words(levels)]{
    level=word(levels,jtype)
    leveltag=word(leveltags,jtype) 

    gens=generators(leveltag)
    gtags=gentags(leveltag)
    print "  Q - ".level
    
    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'variations-Q-'.leveltag.'.pdf'

    do for [imeas=1:words(measures)]{
        # for the Delta measure, indicate Casimir scaling
        if (imeas == 1){
            set arrow 1 from  graph 0.68, first 0.1286 to graph 0.63,first 0.1286 head filled size screen 0.01,25,60 ls 1 lw 1.5 lc rgb '#000000'
            set label 3 '{/*0.8 LL}' left at graph 0.69, first 0.131
        }

        set ylabel 'Separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas,iang)
            set title '{/:Bold '.lambda(kappa,beta).extrax(kappa,beta).', '. level.'} {/: }'

            #plot for [gen in gens] sep("Q","Q",word(measures,imeas),kappa,beta,gen,leveltag) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t escape(gen) w xerr
            plot for [igen=1:words(gens)] sep("Q","Q",word(measures,imeas),kappa,beta,word(gens,igen),leveltag) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t word(gtags,igen) w xerr

        }

	unset arrow 1
	unset label 3
    }
}


#----------------------------------------------------------------------
# alphas variation
# loop over parton and hadron levels
set xlabel '{/Symbol a}_s/{/Symbol a}_{s0}'
unset log x
set xrange [0.7:1.6]
set xtics (0.8, 0.9, 1.0, 1.1, 1.2)

set label 1 '{/*0.9 Q=200 GeV}' right at graph 0.95,0.48
set label 2 '{/*0.9 R=0.6}'     right at graph 0.95,0.42

# for the alphas sweep, manually remove deductor from the list of curves
genindices="1 2 3 4 6 7 8"

do for [jtype=1:words(levels)]{
    level=word(levels,jtype)
    leveltag=word(leveltags,jtype) 
    gens=generators(leveltag)
    gtags=gentags(leveltag)
    print "  alphas - ".level

    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'variations-alphas-'.leveltag.'.pdf'

    do for [imeas=1:words(measures)]{

        # for the Delta measure, indicate Casimir scaling
        if (imeas == 1){
            set arrow 1 from  graph 0.68, first 0.1286 to graph 0.63,first 0.1286 head filled size screen 0.01,25,60 ls 1 lw 1.5 lc rgb '#000000'
            set label 3 '{/*0.8 LL}' left at graph 0.69, first 0.131
        }

        set ylabel 'Separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas,iang)
            set title '{/:Bold '.lambda(kappa,beta).extrax(kappa,beta).', '. level.'} {/: }'

            #plot for [gen in gens] sep("alpha","alphas",word(measures,imeas),kappa,beta,gen,leveltag) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t escape(gen) w xerr
            plot for [igen in genindices] sep("alpha","alphas",word(measures,imeas),kappa,beta,word(gens,igen+0),leveltag) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t word(gtags,igen+0) w xerr ls igen+0
        }

	unset arrow 1
	unset label 3
    }
}


#----------------------------------------------------------------------
# R variation
# loop over parton and hadron levels
set xlabel 'R'
set xrange [0.0:1.8]
set xtics 0.0,0.2,1.2

set label 1 '{/*0.9 Q=200 GeV}' right at graph 0.95,0.48
set label 2 '{/*0.9 {/Symbol a}_s={/Symbol a}_{s0}}' right at graph 0.95,0.42

do for [jtype=1:words(levels)]{
    level=word(levels,jtype)
    leveltag=word(leveltags,jtype) 
    gens=generators(leveltag)
    gtags=gentags(leveltag)
    print "  R - ".level

    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'variations-R-'.leveltag.'.pdf'

    do for [imeas=1:words(measures)]{

        # for the Delta measure, indicate Casimir scaling
        if (imeas == 1){
            set arrow 1 from  graph 0.68, first 0.1286 to graph 0.63,first 0.1286 head filled size screen 0.01,25,60 ls 1 lw 1.5 lc rgb '#000000'
            set label 3 '{/*0.8 LL}' left at graph 0.69, first 0.131
        }

        set ylabel 'Separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas,iang)
            set title '{/:Bold '.lambda(kappa,beta).extrax(kappa,beta).', '. level.'} {/: }'

            #plot for [gen in gens] sep("R","R",word(measures,imeas),kappa,beta,gen,leveltag) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t escape(gen) w xerr
            plot for [igen=1:words(gens)] sep("R","R",word(measures,imeas),kappa,beta,word(gens,igen),leveltag) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t word(gtags,igen) w xerr

        }
	
	unset arrow 1
	unset label 3

    }
}



set out
