# same as sep-v-ang but now we plot each MonteCarlo generator
# separately with internal variations
#
# Included options (full)
#                       Py   Vi  Hw  Sh  De  Ar   ls
#  ""         baseline  vv   vv  vv  vv  vv  vv    1          
#  nogqq      no gqq    vv   vv  vv  vv       v    2    
#  norec      no rec    vv   vv  vv                3
#  nome       no ME     vv   vv                    4     
#  njet0      njet=0                 vv            4
#  njet1      njet=1                 vv            5
#  CR1        CR1       vv                         5
#  CR2        CR2       vv                         6
#  a2L        2-loop    vv   vv                    7    
#  muq        mu_q           vv                    5    
#  dipole                         v                5 
#  dipolenoCR                     v                6
#  noswing                                   vv    3
#
# reduce to 6
#                       Py   Vi  Hw  Sh  De  Ar   ls
#  ""         baseline  vv   vv  vv  vv  vv  vv    1          
#  nogqq      no gqq    vv   vv  vv  vv       v    2    
#  norec      no rec    vv   vv                    3
#  no cr      no CR              vv                3
#  noswing                                   vv    3
#  nome       no ME     vv   vv                    4     
#  njet0      njet=0                 vv            4
#  njet1      njet=1                 vv            5 (drop?)
#  CR1        CR1       vv                         5
#  dipole     dipole              v                4 
#  dipolenoCR dip,no CR           v                5
#  muq        mu_q           vv                    5    
#  a2L        2-loop    vv   vv                    6    
#
# reduce to 5
#                       Py   Vi  Hw  Sh  De  Ar   ls
#  ""         baseline  vv   vv  vv  vv  vv  vv    1          
#  nogqq      no gqq    vv   vv  vv  vv       v    2    
#  no cr      no CR              vv                3
#  noswing                                   vv    3
#  nome       no ME     vv   vv                    3     
#  njet0      njet=0                 vv            3
#  njet1      njet=1                 vv            4
#  dipole     dipole              v                4 
#  dipolenoCR dip,no CR           v                5
#  a2L        2-loop    vv   vv                    4    
#  CR1        CR1       vv                         5
#  muq        mu_q           vv                    5    


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
sep(measure,generator,level,tag)=yodaget(sprintf("separation/%s_",measure), '../'.generator.'/'.level.'/sum-200'.tag.'.yoda')

#----------------------------------------------------------------------
# now really plot things

set key at graph 0.99,0.96

set label 1 '{/*0.9 Q=200 GeV}' left at graph 0.75,0.38
set label 2 '{/*0.9 R=0.6}'     left at graph 0.75,0.32

# loop over parton and hadron levels
do for [level in "parton hadron"]{
    # looop over generators
    gens=generators(level)
    gtags=gentags(level)
    do for [igen=1:words(gens)]{
        gen=word(gens,igen)
        print "  ".gen." - ".level
        
        # hardcode the list of curves (allows for a cleaner title)
        if (gen eq "Pythia-8205"){
            tags='"" -a2L -CR1 -CR2 -nogqq -nome -norec'
            names='"baseline" "2-loop {/Symbol a}_s" CR1 CR2 "no gqq" "no ME" "no rec"'
        }
        if (gen eq "Sherpa-2.1.1"){
            tags='"" -njet0 -njet1 -nogqq'
            names='"baseline" "njet=0" "njet=1" "no gqq"'
        }
        if (gen eq "Vincia-1201"){
            tags='"" -a2L -muq -nome -noqgg -norec'
            names='"baseline" "2-loop {/Symbol a}_s" "{/Symbol m}_q" "no ME" "no qgg" "no rec"'
        }
        if (gen eq "Herwig-2_7_1"){
            tags='"" -nogqq'
            names='"baseline" "no gqq"'
        }
        if (gen eq "Deductor-1.0.2"){
            tags='""'
            names='"baseline"'
        }
        if (gen eq "Ariadne"){
            tags='"" -noswing'
            names='"baseline" "no swing"'
        }

        # the following plots (loop over separation measures) all go in
        # the same file
        set out 'sep-v-ang-'.gen.'-'.level.'.pdf'
        set title '{/:Bold '.word(gtags,igen).', '.level.'} {/: }'
        
        do for [imeas=1:words(measures)]{
            set ylabel 'separation: '.word(mlabs,imeas)
            set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]
            
            plot for [itag=1:words(tags)] sep(word(measures,imeas),gen,level,word(tags,itag)) u (0.5*($1+$2)):3:(0.5*($2-$1)) t word(names,itag) w xerr
        }
    }
}

set out
