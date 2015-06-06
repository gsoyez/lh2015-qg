#!/bin/bash
#
# prepare results and plots
#
# This assumes that
#   . each generator has its own directory

# record some logs in that file
logfile=post-process.log
date > $logfile

#desired_generators="Herwig-2_7_1 Pythia-8.??? Vincia-??? Sherpa-2.1.1"
desired_generators="Sherpa-2.1.1"

#----------------------------------------------------------------------
# a helper to output to stdout and logfile
function message {
    echo "$1" | tee -a $logfile
}

# calls rivet-mkhtml with the same argument only if the directory does not exist
#
# at the moment, the first arguments have to be -o output_dir    
function safe-rivet-mkhtml {
    plot_dir="$2"
    if [ -d $plot_dir ] && [ -z $FORCE ] && [ -z $FORCE_PLOTS ]; then
        message "...... $plot_dir already already done. Delete the directory or run FORCE_PLOTS=yes to redo"
    else
        rivet-mkhtml $@ >> logfile 2>&1
    fi
}

#----------------------------------------------------------------------
# generic generators
message ""
message "Building the list of supported generators"
generators=""
for gen in $desired_generators; do
    if [ -d $gen/results ]; then
        generators="$generators $gen"
    fi
done
message "... Will work with $generators"

# compute separations
message ""
message "Computing separations"
for gen in $generators; do
    message "... $gen"
    for fn in $gen/results/uu*.yoda; do
        gluname=${fn/uu/gg}
        if [ -f ${gluname} ]; then
            sepname=${fn/uu/sep}
            if [ ! -f ${sepname} ] || [ ! -z $FORCE ]; then
                logname=${sepname%yoda}log
                ./compute-efficiencies.py $fn ${gluname} $sepname > $logname
                ./produce-separation-data.py ${logname} ${sepname/sep/sum}
            fi
        fi
    done
done

# make plots for each of the generators
message ""
message "Plots for individual generators at 200 GeV, R=0.6"
for gen in $generators; do
    message "... $gen"

    # build the list of the files to be plottes
    # we separate the quark, gluon and common files for linedtyle purpose
    #
    # At the same time we build the list of generators to include in
    # the combined plot
    q_only_files=""
    g_only_files=""
    q_both_files=""
    g_both_files=""

    # search for the quark (and common) ones
    for fn in $gen/results/uu-200*.yoda; do
        if [[ $fn != *"-alphasx"* ]]; then
            gluname=${fn/uu/gg}
            if [ -f ${gluname} ]; then
                q_both_files="$q_both_files $fn"
                g_both_files="$g_both_files $gluname"
            else
                q_only_files="$q_only_files $fn"
            fi
        fi
    done

    # search for the gluon-only ones
    for fn in $gen/results/gg-200*.yoda; do
        if [[ $fn != *"-alphasx"* ]]; then
            quarkname=${fn/uu/gg}
            if [ ! -f ${quarkname} ]; then
                g_only_files="$g_only_files $fn"
            fi
        fi
    done

    message "...... quark: $q_both_files $q_only_files"
    message "...... gluon: $g_both_files $g_only_files"    

    # build the "separation" list
    s_files=${q_both_files//uu/sep}
    message "...... separ: $s_files"    
    
    # append the flags to these lists so that the titles come out right
    q_input=""
    for tag in $q_both_files $q_only_files; do
        noyoda=${tag%.yoda}; flags=${noyoda#*uu-200}
        if [ -z $flags ]; then flags="best"; else flags=${flags#-}; fi
        q_input="$q_input $tag:$flags"
    done
    message "...... plot quark: $q_input"    

    g_input=""
    for tag in $g_both_files $g_only_files; do
        noyoda=${tag%.yoda}; flags=${noyoda#*gg-200}
        if [ -z $flags ]; then flags="best"; else flags=${flags#-}; fi
        g_input="$g_input $tag:$flags"
    done
    message "...... plot gluon: $g_input"

    s_input=""
    for tag in $s_files; do
        noyoda=${tag%.yoda}; flags=${noyoda#*sep-200}
        if [ -z $flags ]; then flags="best"; else flags=${flags#-}; fi
        s_input="$s_input $tag:$flags"
    done
    message "...... plot separ: $s_input"

    # generate the list for the for the "integrated quality" plot
    i_input=${s_input//sep/sum}
    message "...... plot integ: $i_input"
    
    # the trick below should work as far as I understand the manual
    # correctly but crashes rivet-cmphistos. So we disable it for now. 
    # Once it is working, replace -c MC_LHQG_EE.plot below by -c tmp.plot
    ## 
    ## # build a custom build plot
    ## echo "# BEGIN PLOT" > tmp.plot
    ## echo "DrawOnly=GA_00_00_R06 GA_20_00_R06 GA_10_05_R06 GA_10_10_R06 GA_10_20_R06 log_GA_00_00_R06 log_GA_20_00_R06 log_GA_10_05_R06 log_GA_10_10_R06 log_GA_10_20_R06" >> tmp.plot
    ## echo "# END PLOT" >> tmp.plot
    ## echo "" >> tmp.plot
    ## cat MC_LHQG_EE.plot >> tmp.plot
    
    # do the plots
    safe-rivet-mkhtml -o plots/uu-200-R06-$gen  $q_input -c MC_LHQG_EE.plot -t $gen,Q=200GeV,R=0.6
    safe-rivet-mkhtml -o plots/gg-200-R06-$gen  $g_input -c MC_LHQG_EE.plot -t $gen,Q=200GeV,R=0.6
    safe-rivet-mkhtml -o plots/sep-200-R06-$gen $s_input -c MC_LHQG_EE.plot -t $gen,Q=200GeV,R=0.6
    safe-rivet-mkhtml -o plots/sum-200-R06-$gen $i_input -t $gen,Q=200GeV,R=0.6
done

# do the MC comparison on the baseline
message ""
message "Plots for generator comparison at 200 GeV, R=0.6"
q_input=""
g_input=""
s_input=""
i_input=""
for gen in $generators; do
    q_input="$q_input $gen/results/uu-200.yoda:$gen"
    g_input="$g_input $gen/results/gg-200.yoda:$gen"
    s_input="$s_input $gen/results/sep-200.yoda:$gen"
    i_input="$i_input $gen/results/sum-200.yoda:$gen"
done
message "... plot quark: $q_input"    
message "... plot gluon: $g_input"
message "... plot separ: $s_input"
message "... plot integ: $i_input"
    
# the trick below should work as far as I understand the manual
# correctly but crashes rivet-cmphistos. So we disable it for now. 
# Once it is working, replace -c MC_LHQG_EE.plot below by -c tmp.plot
## 
## # build a custom build plot
## echo "# BEGIN PLOT" > tmp.plot
## echo "DrawOnly=GA_00_00_R06 GA_20_00_R06 GA_10_05_R06 GA_10_10_R06 GA_10_20_R06 log_GA_00_00_R06 log_GA_20_00_R06 log_GA_10_05_R06 log_GA_10_10_R06 log_GA_10_20_R06" >> tmp.plot
## echo "# END PLOT" >> tmp.plot
## echo "" >> tmp.plot
## cat MC_LHQG_EE.plot >> tmp.plot
    
# do the plots
safe-rivet-mkhtml -o plots/uu-200-R06-allMCs  $q_input -c MC_LHQG_EE.plot -t $gen,Q=200GeV,R=0.6
safe-rivet-mkhtml -o plots/gg-200-R06-allMCs  $g_input -c MC_LHQG_EE.plot -t $gen,Q=200GeV,R=0.6
safe-rivet-mkhtml -o plots/sep-200-R06-allMCs $s_input -c MC_LHQG_EE.plot -t $gen,Q=200GeV,R=0.6
safe-rivet-mkhtml -o plots/sum-200-R06-allMCs $i_input -t $gen,Q=200GeV,R=0.6

#----------------------------------------------------------------------
# do the alphas modulation
mkdir -p modulations
message ""
message "Plots of the alphas modulation for individual generators at 200 GeV, R=0.6"
for gen in $generators; do
    message "... $gen"
    ./produce-alphadependence-data.py $gen modulations/alphadep-$gen.yoda
    i_input="$i_input modulations/alphadep-$gen.yoda:$gen"
done
# config file missing
safe-rivet-mkhtml -o plots/alphadependence $i_input -t Q=200GeV,R=0.6

# do the R modulation
message ""
message "Plots of the R modulation for individual generators at 200 GeV"
i_input=""
for gen in $generators; do
    message "... $gen"
    ./produce-Rdependence-data.py $gen/results/sep-200.log modulations/Rdep-$gen.yoda
    i_input="$i_input modulations/Rdep-$gen.yoda:$gen"
done
# config file missing
safe-rivet-mkhtml -o plots/Rdependence $i_input -t Q=200GeV


# do the energy modulation
message ""
message "Plots of the Q modulation for individual generators at R=0.6"
i_input=""
for gen in $generators; do
    message "... $gen"
    ./produce-Qdependence-data.py $gen modulations/Qdep-$gen.yoda
    i_input="$i_input modulations/Qdep-$gen.yoda:$gen"
done
# config file missing
safe-rivet-mkhtml -o plots/Qdependence $i_input -t R=0.6

message "all done!"
date | tee -a $logfile
