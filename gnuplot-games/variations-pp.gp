# plot the dependence of the separation as a function of several
# physics parameters: pTmin, R and the alphas value

call 'common-pp.gp'

#----------------------------------------------------------------------

# only do phadron level
level="Hadron-level"
leveltag="hadron"


# do plain jet and mmdt
modes='plain mMDT'
modetags='"" "mMDT_"'

pTmin=100
R=0.4

# the shapes (we made sure that LHA was first, it might be more
# convenient to keep the ordering the same as when we plot things with
# the shape as x-axis)
kappas="1   1 1 0 2"
betas ="0.5 1 2 0 0"

# get the label associated with a shape
lambda(kappa,beta)=sprintf("{/Symbol l}@^{%s}_{%s}", kappa, beta)
extrax(kappa,beta)=(beta==0.5 && kappa==1) ? ' [LHA]' : (beta>0) ? '' : (kappa==0) ? ' [multiplicity]' : (kappa==2) ? ' [(p@_T^D)^2]' : ''

# extract a given distribution from a given file
sep(var,varin,measure,kappa,beta,generator,mode)=yodaget(sprintf("%sdependence/%s%s_GA_%02d_%02d",varin,mode,measure,10*kappa,10*beta), '../modulations/lhc/'.var.'dep-'.generator.'-'.leveltag.'.yoda')

#----------------------------------------------------------------------
# now really plot things

#set key at graph 0.99,0.04 bottom right
set key at graph 0.99,0.96

#----------------------------------------------------------------------
# pTmin variation
# loop over parton and hadron levels
set xlabel 'p@_T^{min} [GeV]'
set xrange [30:12000]
set xtics (40 1,50,60 1,70 1,80 1,90 1,100,200,300 1,400 1,500,600 1,700 1,800 1,900 1,1000)
set log x

set label 1 sprintf('{/*0.9 R=%g}', R)  right at graph 0.95,0.48

# loop over parton and hadron levels
do for [imode=1:words(modes)]{
    mode=word(modes,imode)
    modetag=word(modetags,imode) 

    gens=generators(leveltag)
    gtags=gentags(leveltag)
    print "  pTmin - ".mode
    
    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'variations-pTmin-pp-'.mode.'.pdf'

    do for [imeas=1:words(measures)]{

        set ylabel 'Separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas,iang)
            set title '{/:Bold '.lambda(kappa,beta).extrax(kappa,beta).', '. level.', '. level.', '.mode.' jet} {/: }'

            plot for [igen=1:words(gens)] sep("Q","Q",word(measures,imeas),kappa,beta,word(gens,igen),modetag) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t word(gtags,igen) w xerr


        }

    }
}

unset log x

#----------------------------------------------------------------------
# R variation
# loop over parton and hadron levels
set xlabel 'R'
set xrange [0.0:1.8]
set xtics 0.0,0.2,1.2

set label 1 sprintf('{/*0.9 p@_T^{min}=%d GeV}',pTmin) right at graph 0.95,0.48

do for [imode=1:words(modes)]{
    mode=word(modes,imode)
    modetag=word(modetags,imode) 
    gens=generators(leveltag)
    gtags=gentags(leveltag)
    print "  R - ".mode

    # the following plots (loop over separation measures) all go in
    # the same file
    set out 'variations-R-pp-'.mode.'.pdf'

    do for [imeas=1:words(measures)]{

        set ylabel 'Separation: '.word(mlabs,imeas)
        set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas,iang)
            set title '{/:Bold '.lambda(kappa,beta).extrax(kappa,beta).', '. level.', '.mode.' jet} {/: }'

            #plot for [gen in gens] sep("R","R",word(measures,imeas),kappa,beta,gen,leveltag) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t escape(gen) w xerr
            plot for [igen=1:words(gens)] sep("R","R",word(measures,imeas),kappa,beta,word(gens,igen),modetag) u (sqrt($1*$2)):(treat_zero_as_nan($3)):1:2 t word(gtags,igen) w xerr

        }
    }
}



set out
