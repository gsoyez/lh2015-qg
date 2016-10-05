# plot quark, gluon and separation distributions comparing the
# generators (each page of the pdf corresponds to a different
# generalised angularity)

call 'common-pp.gp'

#----------------------------------------------------------------------
# the different types of distributions we shall plot
types="Z+j 2j Separation"
typetags="zjet dijet sep"

# only do hadron level
level="Hadron-level"
leveltag="hadron"

# do plain jet and mmdt
modes='plain mMDT'
modetags='"" "mMDT_"'

Q=100
R=0.4

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

# we also want the same yrange for the parton and hadron level
# we'll also try the same for Zj and jj (but different for the separation)

ymaxs="6.0 12.0 25.0 0.36 13.0 6.0 12.0 25.0 0.36  13.0 2.0  4.0  9.0 0.06  3.0"

# get the label associated with a shape
lambda(kappa,beta)=sprintf("{/Symbol l}@^{%s}_{%s}", kappa, beta)
extrax(kappa,beta)=(beta==0.5 && kappa==1) ? ' [LHA]' : (beta>0) ? '' : (kappa==0) ? ' [multiplicity]' : (kappa==2) ? ' [(p@_T^D)^2]' : ''

# extract a given distribution from a given file
distrib(kappa,beta,typetag,generator,mode,nreb)=yodaget(sprintf("%sGA_%02d_%02d_Q%d_R%d",mode,10*kappa,10*beta,Q,10*R), '../'.generator.'/lhc/'.leveltag.'/'.typetag.'.yoda').' | ./rebin.pl -2 -rc '.nreb

#----------------------------------------------------------------------
# now really plot things

set yrange [0:]
set key at graph 0.99,0.96

set label 1 sprintf('{/*0.9 Q=%d GeV}',Q) right at graph 0.95,0.48
set label 2 sprintf('{/*0.9 R=%g}',R)     right at graph 0.95,0.42

# loop over quarks, gluons and separation
do for [itype=1:words(types)]{
    type=word(types, itype)
    typetag=word(typetags, itype)

    # loop over parton and hadron levels
    do for [imode=1:words(modes)]{
        mode=word(modes,imode)
        modetag=word(modetags,imode) 
        gens=generators(leveltag)
        gtags=gentags(leveltag)
        print "  ".type." - ".mode

        # the following plots (loop over angularitues) all go in the
        # same file
        set out 'distributions-'.typetag.'-pp-'.mode.'.pdf'
        set title '{/:Bold '.type.', '.level.', '.mode.' jet} {/: }'

        do for [iang=1:words(kappas)]{
            kappa=word(kappas,iang)
            beta =word(betas, iang)
            set xrange [0:word(xmaxs,iang)+0.0]
            set xtics word(xtics,iang)+0.0
            set mxtics word(mtics,iang)+0
            nreb=word(rebins, iang)
            set xlabel lambda(kappa,beta).extrax(kappa,beta)

            set ylabel ((itype==1) ? 'p_{Zj}('.lambda(kappa,beta).')' : (itype==2) ? 'p_{2j}('.lambda(kappa,beta).')' : 'd{/Symbol D}\/d'.lambda(kappa,beta) )
            set yrange [0:word(ymaxs,(itype-1)*words(kappas)+iang)+0.0]
	
            plot for [igen=1:words(gens)] distrib(kappa,beta,typetag,word(gens,igen),modetag,nreb) u 2:4 t word(gtags,igen) w l
        }
    }
}

set out
