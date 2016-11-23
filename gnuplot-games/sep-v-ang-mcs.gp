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
#                       Py   Vi  Hw  Sh  De  Di  Ar   ls
#  ""         baseline  vv   vv  vv  vv  vv  vv  vv    1          
#  nogqq      no gqq    vv   vv  vv  vv           v    2    
#  no cr      no CR              vv                    3
#  noswing                                       vv    3
#  nome       no ME     vv   vv                        3     
#  njet0      njet=0                 vv                3
#  njet1      njet=1                 vv                4
#  dipole     dipole              v                    4 
#  dipolenoCR dip,no CR           v                    5
#  a2L        2-loop    vv   vv                        4    
#  CR1        CR1       vv                             5
#  muq        mu_q           vv                        5    
#  as1L                                      vv        4
#  as3l                                      vv        5
#  mcnlo                                     vv        3
#  string                                    vv        2



call 'common.gp'

#----------------------------------------------------------------------
# the different levels of distributions we shall plot
levels="parton-level hadron-level"
leveltags="parton hadron"

# the shapes (we made sure that LHA was first, it might be more
# convenient to keep the ordering the same as when we plot things with
# the shape as x-axis)
set xtics ("(0,0)" 0, "(2,0)" 1, "(1,0.5)" 2, "(1,1)" 3, "(1,2)" 4)
set xlabel 'Angularity: ({/Symbol k},{/Symbol b})'
set xrange [-0.5:7.6]

# extract a given distribution from a given file
sep(measure,generator,leveltag,tag)=yodaget(sprintf("separation/%s_",measure), '../'.generator.'/'.leveltag.'/sum-200'.tag.'.yoda')

#----------------------------------------------------------------------
# now really plot things

set key at graph 0.99,0.96

set label 1 '{/*0.9 Q=200 GeV}' right at graph 0.95,0.48
set label 2 '{/*0.9 R=0.6}'     right at graph 0.95,0.42

# loop over parton and hadron levels
do for [jtype=1:words(levels)]{
    level=word(levels,jtype)
    leveltag=word(leveltags,jtype) 

    # looop over generators
    gens=generators(leveltag)
    gtags=gentags(leveltag)
    do for [igen=1:words(gens)]{
        gen=word(gens,igen)
        print "  ".gen." - ".level
        
        # hardcode the list of curves (allows for a cleaner title)
        if (gen eq "Pythia-8205"){
            tags='"" -nogqq -nome -a2L -CR1'
            names='"baseline" "no g{/Symbol \256}q~q‾" "no ME" "2-loop {/Symbol a}_s" "CR1"'
        }
        if (gen eq "Sherpa-2.1.1"){
            tags='"" -nogqq -njet0 -njet1 '
            names='"baseline" "no g{/Symbol \256}q~q‾" "N_{jet}=0" "N_{jet}=1" '
        }
        if (gen eq "Vincia-1201"){
            tags='"" -noqgg -nome -a2L -muq'
            names='"baseline" "no g{/Symbol \256}q~q‾" "no ME" "2-loop {/Symbol a}_s" "alt {/Symbol m}_q"'
        }
        if (gen eq "Herwig-2_7_1"){
            tags='"" -nogqq -nocr'
            names='"baseline" "no g{/Symbol \256}q~q‾" "no CR"'
        }
        if (gen eq "Herwig-7.0.3"){
            tags='"" -nogqq -nocr'
            names='"baseline" "no g{/Symbol \256}q~q‾" "no CR"'
        }
        if (gen eq "Deductor-1.0.2"){
            tags='""'
            names='"baseline"'
        }
        if (gen eq "Ariadne"){
            tags='"" -nogqq -noswing'
            names='"baseline" "no g{/Symbol \256}q~q‾" "no swing"'
        }

        if (gen eq "Dire-1.0.0"){
            tags='"" -nogqq -mcnlo -as0 -as2 -string'
            names='"baseline" "no g{/Symbol \256}q~q‾" "MC{\100}NLO" "1-loop {/Symbol a}_s" "3-loop {/Symbol a}_s" "string had." '
        }

        if (gen eq "AnalyticResum"){
            tags='"" -nogqq -noNGL -no2loop -noCas -altF'
            names='"baseline" "no g{/Symbol \256}q~q‾" "no NGLs" "no 2-loop {/Symbol a}_s" "no C_i in {/Symbol e}_0" "alt F({/Symbol e})"'
        }

        # the following plots (loop over separation measures) all go in
        # the same file
        set out 'sep-v-ang-'.gen.'-'.leveltag.'.pdf'
        set title '{/:Bold '.word(gtags,igen).', '.level.'} {/: }'
        
        do for [imeas=1:words(measures)]{
            set ylabel 'Separation: '.word(mlabs,imeas)
            set yrange [word(ymins,imeas)+0.0:word(ymaxs,imeas)+0.0]
            
            plot for [itag=1:words(tags)] sep(word(measures,imeas),gen,leveltag,word(tags,itag)) u (0.5*($1+$2)):3:(0.5*($2-$1)) t word(names,itag) w xerr
        }
    }
}

set out
