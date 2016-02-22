# plot quark, gluon and separation distributions comparing the
# generators (each page of the pdf corresponds to a different
# generalised angularity)

call 'common.gp'

#----------------------------------------------------------------------
# the different types of distributions we shall plot
types="Quark Gluon Separation"
typetags="uu gg sep"

# the different levels of distributions we shall plot
levels="parton-level hadron-level"
leveltags="parton hadron"

# the shapes (we made sure that LHA was first, it might be more
# convenient to keep the ordering the same as when we plot things with
# the shape as x-axis)
kappas="1   1 1 0 2"
betas ="0.5 1 2 0 0"

# shape-dependent adjustments
xmaxs ="1.0 1.0 1.0 50 1.0"
xtics ="0.2 0.2 0.2 10 0.2"
mtics ="4   4   4   5  4"
rebins="5   5   5   1  5"

# get the label associated with a shape
lambda(kappa,beta)=sprintf("{/Symbol l}@^{%s}_{%s}", kappa, beta)
extrax(kappa,beta)=(beta==0.5 && kappa==1) ? ' [LHA]' : (beta>0) ? '' : (kappa==0) ? ' [multiplicity]' : (kappa==2) ? ' [(p@_T^D)^2]' : ''

# extract a given distribution from a given file
distrib(kappa,beta,typetag,generator,level,nreb)=yodaget(sprintf("GA_%02d_%02d_R6",10*kappa,10*beta), '../'.generator.'/'.level.'/'.typetag.'-200.yoda').' | ./rebin.pl -2 -rc '.nreb

#----------------------------------------------------------------------
# now really plot things

set yrange [0:]
set key at graph 0.99,0.96

set label 1 '{/*0.9 Q=200 GeV}' right at graph 0.95,0.48
set label 2 '{/*0.9 R=0.6}'     right at graph 0.95,0.42

# loop over quarks, gluons and separation
do for [itype=1:words(types)]{
    type=word(types, itype)
    typetag=word(typetags, itype)

    # loop over parton and hadron levels
    do for [jtype=1:words(levels)]{
        level=word(levels,jtype)
        leveltag=word(leveltags,jtype) 
        gens=generators(leveltag)
        gtags=gentags(leveltag)
        print "  ".type." - ".level

        # the following plots (loop over angularitues) all go in the
        # same file
        set out 'distributions-'.typetag.'-'.leveltag.'.pdf'
        set title '{/:Bold '.type.', '.level.'} {/: }'

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas, iang)
            set xrange [0:word(xmaxs,iang)+0.0]
            set xtics word(xtics,iang)+0.0
            set mxtics word(mtics,iang)+0
            nreb=word(rebins, iang)

            set xlabel lambda(kappa,beta).extrax(kappa,beta)
            #set ylabel '1/N dN/d'.lambda(kappa,beta)
            set ylabel ((itype==1) ? 'p_q('.lambda(kappa,beta).')' : (itype==2) ? 'p_g('.lambda(kappa,beta).')' : 'd{/Symbol D}\/d'.lambda(kappa,beta) )
	
            plot for [igen=1:words(gens)] distrib(kappa,beta,typetag,word(gens,igen),leveltag,nreb) u 2:4 t word(gtags,igen) w l
        }
    }
}

set out
