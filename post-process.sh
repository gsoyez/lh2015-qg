#!/bin/bash
#
# prepare results and plots
#
# This assumes that the file format is as described in the README.md
# file.
#
# Note that this scripts avoids to re-generate information that is
# already there. You can use
#
#   FORCE=yes ./post-process.sh
#
# to force the re-generation of everything.
#
# As an alternative, you can remove the sub-directory in plots/ that
# corresponds to the plots that have to be re-generated.
#
# Possible improvements:
#  - use modification times to see if something needs to be regenerated
#  - in safe-rivet-mkhtml, browse the arguments so as not to force the
#    presence of -o output_dir as the forst arguments.

# record some logs in that file
logfile=post-process.log
date > $logfile

# add Herwig later since it's not done yet:
desired_generators="Pythia-8205 Sherpa-2.1.1 Vincia-1201 Herwig-2_7_1 Deductor-1.0.2"
# Herwig-7-dipole AnalyticResum


#----------------------------------------------------------------------
# a helper to output both to stdout and logfile
function message {
    echo "$1" | tee -a $logfile
}

# calls rivet-mkhtml with the same argument only if the directory does not exist
#
# at the moment, the first arguments have to be "-o output_dir"
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
    if [ -d $gen/hadron ] || [ -d $gen/parton ]; then
        generators="$generators $gen"
    fi
done
message "... Will work with $generators"

# while we go on with all the plots and build of the extra info, we
# shall make a snall webpage to ease naviogation through everything
if [ ! -d plots ]; then
    mkdir plots
fi
message "Starting summary webpage as plots/index.html"
web_global="plots/index.html"

cat  > $web_global <<EOF
<html>
<head>
<title>Quark-gluon studies for Les-Houches 2015</title>
<style>
  html { font-family: sans-serif; }
  img { border: 0; }
  a { text-decoration: none; }
  table { border: 1; cellpadding: 5; cellspacing: 1; }
</style>
<script type="text/x-mathjax-config">
MathJax.Hub.Config({
  tex2jax: {inlineMath: [["$","$"]]}
});
</script>
<script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLo
rMML">
</script>
</head>
<body><h2>Quark-gluon studies for Les-Houches 2015</h2>
EOF


# compute separations
message ""
message "Computing separations"
for gen in $generators; do
    for level in hadron parton; do
        message "... $gen --- $level"
        for fn in $gen/${level}/uu*.yoda; do
            gluname=${fn/uu/gg}
            if [ -f ${gluname} ]; then
                sepname=${fn/uu/sep}
                if [ ! -f ${sepname} ] || [ ! -z $FORCE ]; then
                    logname=${sepname%yoda}log
                    # check if the files differ
                    if diff $fn ${gluname} > /dev/null ; then
                        echo "...... WARNING: ${fn} $gluname HAVE THE SAME CONTENTS"
                    fi
                    # do the computation
                    ./compute-efficiencies.py $fn ${gluname} $sepname > $logname
                    ./produce-separation-data.py ${logname} ${sepname/sep/sum}
                fi
            fi
        done
    done
done

# make plots for each of the generators
# Note that here we will only plot the _R06 results
# We also only do the plot if there is more than 1 file
mkdir -p post-process-tmpfiles
rm -Rf post-process-tmpfiles/*
message ""
message "Plots for individual generators at 200 GeV, R=0.6"

echo "<h3>Distributions for individual generators</h3>" >> $web_global
echo "<table border=\"1\" cellspacing=\"0\" cellpadding=\"3\">" >> $web_global
echo "<tr><th>generator</th><th colspan=\"5\">hadron</th><th colspan=\"5\">parton</th>" >> $web_global
for gen in $generators; do
    echo -n "<tr><td>$gen</td>" >> $web_global
    for level in hadron parton; do
        message "... $gen --- $level"

        # clean things up
        mkdir post-process-tmpfiles/u
        mkdir post-process-tmpfiles/g
        mkdir post-process-tmpfiles/s
        mkdir post-process-tmpfiles/i

        # build the list of the files to be plotted
        # we separate the quark, gluon and common files for linedtyle purpose
        #
        # At the same time we build the list of generators to include in
        # the combined plot
        q_only_files=""
        g_only_files=""
        q_both_files=""
        g_both_files=""

        # search for the quark (and common) ones
        # make sure that the baseline comes first
        if [ -f $gen/${level}/uu-200.yoda ]; then 
            q_both_files="$gen/${level}/uu-200.yoda"
        fi
        if [ -f $gen/${level}/gg-200.yoda ]; then 
            g_both_files="$gen/${level}/gg-200.yoda"
        fi
        for fn in `ls $gen/${level}/uu-200-*.yoda 2>/dev/null`; do
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
        for fn in `ls $gen/${level}/gg-200-*.yoda 2>/dev/null`; do
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
            if [ -z $flags ]; then flags="baseline"; else flags=${flags#-}; fi
            yodacnv $tag -m "GA.*_R6|/Thrust" post-process-tmpfiles/u/${flags}.yoda
            q_input="$q_input post-process-tmpfiles/u/${flags}.yoda"
            #q_input="$q_input $tag:$flags"
        done
        message "...... plot quark: $q_input"    

        g_input=""
        for tag in $g_both_files $g_only_files; do
            noyoda=${tag%.yoda}; flags=${noyoda#*gg-200}
            if [ -z $flags ]; then flags="baseline"; else flags=${flags#-}; fi
            yodacnv $tag -m "GA.*_R6|/Thrust" post-process-tmpfiles/g/${flags}.yoda
            g_input="$g_input post-process-tmpfiles/g/${flags}.yoda"
        done
        message "...... plot gluon: $g_input"

        # generate the list for the separation plots and for the for the
        # "integrated quality" plot. For the latter, only R=0.6 enters the
        # tables so we can directly use the sum files
        #
        # We also generate a list of labels that will go on the html page
        s_input=""
        i_input=""
        labels=""
        for tag in $s_files; do
            noyoda=${tag%.yoda}; flags=${noyoda#*sep-200}
            if [ -z $flags ]; then
                flags="baseline";
                labels="base"
            else
                flags=${flags#-};
                labels="${labels}, $flags"
            fi
            i_input="$i_input $tag:$flags"
            yodacnv $tag -m "GA.*_R6" post-process-tmpfiles/s/${flags}.yoda
            s_input="$s_input post-process-tmpfiles/s/${flags}.yoda"
        done
        message "...... plot separ: $s_input"

        i_input=${i_input//sep/sum}
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

        # prepare the style file with the appropriate labels
        
        # do the plots
        spc="${q_input//[^ ]}";
        if [[ ${#spc} < 2 ]]; then
            message "...... only one quark input, no need to plot"
            echo -n "<td align=\"center\">-</td>" >> $web_global
        else
            sed "s/@GENLABEL@/quark, $gen, $level, Q=200GeV/g"        style-variations.plot > style-variations-tmp.plot
            safe-rivet-mkhtml -o plots/uu-200-R06-$gen-$level  $q_input -c style-variations-tmp.plot -t $gen,Q=200GeV,R=0.6
            echo -n "<td><a target=\"_blank\" href=\"uu-200-R06-$gen-$level/MC_LHQG_EE/index.html\">quark</a></td>" >> $web_global
        fi
        spc="${g_input//[^ ]}";
        if [[ ${#spc} < 2 ]]; then
            message "...... only one gluon input, no need to plot"
            echo -n "<td align=\"center\">-</td>" >> $web_global
        else
            sed "s/@GENLABEL@/gluon, $gen, $level, Q=200GeV/g"        style-variations.plot > style-variations-tmp.plot
            safe-rivet-mkhtml -o plots/gg-200-R06-$gen-$level  $g_input -c style-variations-tmp.plot -t $gen,Q=200GeV,R=0.6
            echo -n "<td><a target=\"_blank\" href=\"gg-200-R06-$gen-$level/MC_LHQG_EE/index.html\">gluon</a></td>" >> $web_global
        fi
        spc="${s_input//[^ ]}";
        if [[ ${#spc} < 2 ]]; then
            message "...... only one separation input, no need to plot"
            echo -n "<td align=\"center\">-</td>" >> $web_global
        else
            sed "s/@GENLABEL@/separation, $gen, $level, Q=200GeV/g"        style-variations.plot > style-variations-tmp.plot
            safe-rivet-mkhtml -o plots/sep-200-R06-$gen-$level $s_input -c style-variations-tmp.plot -t $gen,Q=200GeV,R=0.6
            echo -n "<td><a target=\"_blank\" href=\"sep-200-R06-$gen-$level/MC_LHQG_EE/index.html\">separation</a></td>" >> $web_global
        fi
        spc="${i_input//[^ ]}";
        if [[ ${#spc} < 2 ]]; then
            message "...... only one summary input, no need to plot"
            echo -n "<td align=\"center\">-</td>" >> $web_global
        else
            sed "s/@GENLABEL@/$gen, $level, Q=200GeV, R=0.6/g" style-separation.plot > style-separation-tmp.plot
            safe-rivet-mkhtml -o plots/sum-200-R06-$gen-$level $i_input -c style-separation-tmp.plot -t $gen,Q=200GeV,R=0.6
            echo -n "<td><a target=\"_blank\" href=\"sum-200-R06-$gen-$level/separation/index.html\">summary</a></td>" >> $web_global
        fi

        # show the list of flags in the sumamry table
        echo -n "<td align=\"left\">${labels}</td>" >> $web_global

        rm -Rf post-process-tmpfiles/*
    done # level
    echo "</tr>" >> $web_global
done # MC gen
echo "</table>" >> $web_global


# do the MC comparison on the baseline
message ""
message "Plots for generator comparison at 200 GeV, R=0.6"
for level in hadron parton; do
    message "... $level"
    q_input=""
    g_input=""
    s_input=""
    i_input=""
    mkdir post-process-tmpfiles/u
    mkdir post-process-tmpfiles/g
    mkdir post-process-tmpfiles/s
    mkdir post-process-tmpfiles/i
    for gen in $generators; do
        if [ -f $gen/${level}/uu-200.yoda ]; then
           yodacnv $gen/${level}/uu-200.yoda  -m "GA.*_R6|/Thrust" post-process-tmpfiles/u/${gen}.yoda
           q_input="$q_input post-process-tmpfiles/u/${gen}.yoda"
        fi
        if [ -f $gen/${level}/gg-200.yoda ]; then
           yodacnv $gen/${level}/gg-200.yoda  -m "GA.*_R6|/Thrust" post-process-tmpfiles/g/${gen}.yoda
           g_input="$g_input post-process-tmpfiles/g/${gen}.yoda "
        fi
        if [ -f $gen/${level}/sep-200.yoda ]; then 
           yodacnv $gen/${level}/sep-200.yoda -m "GA.*_R6" post-process-tmpfiles/s/${gen}.yoda
           s_input="$s_input post-process-tmpfiles/s/${gen}.yoda"
        fi
        if [ -f $gen/${level}/sum-200.yoda ]; then
           yodacnv $gen/${level}/sum-200.yoda post-process-tmpfiles/i/${gen}.yoda
           i_input="$i_input post-process-tmpfiles/i/${gen}.yoda"
        fi
    done
    message "... plot quark: $q_input"    
    message "... plot gluon: $g_input"
    message "... plot separ: $s_input"
    message "... plot integ: $i_input"

    # prepare the style file with the appropriate labels
        
    # do the plots
    sed "s/@GENLABEL@/quark, $level, Q=200GeV/g"      style-variations.plot > style-variations-tmp.plot
    safe-rivet-mkhtml -o plots/uu-200-R06-allMCs-${level}  $q_input -c style-variations-tmp.plot -t Q=200GeV,R=0.6
    sed "s/@GENLABEL@/gluon, $level, Q=200GeV/g"      style-variations.plot > style-variations-tmp.plot
    safe-rivet-mkhtml -o plots/gg-200-R06-allMCs-${level}  $g_input -c style-variations-tmp.plot -t Q=200GeV,R=0.6
    sed "s/@GENLABEL@/separation, $level, Q=200GeV/g" style-variations.plot > style-variations-tmp.plot
    safe-rivet-mkhtml -o plots/sep-200-R06-allMCs-${level} $s_input -c style-variations-tmp.plot -t Q=200GeV,R=0.6
    sed "s/@GENLABEL@/$level, Q=200GeV, R=0.6/g" style-separation.plot > style-separation-tmp.plot
    safe-rivet-mkhtml -o plots/sum-200-R06-allMCs-${level} $i_input -c style-separation-tmp.plot -t Q=200GeV,R=0.6

    rm -Rf post-process-tmpfiles/*
done

#----------------------------------------------------------------------
# do the alphas modulation
mkdir -p modulations
message ""
message "Plots of the alphas, Q and R modulation for individual generators at 200 GeV, R=0.6"
for level in hadron parton; do
    message "... $level"
    i_input=""
    a_input=""
    for gen in $generators; do
        message "... $gen"

        # skip if the base files are not present
        if [ ! -f $gen/${level}/sep-200.log ]; then continue; fi
        
        ./produce-alphadependence-data.py $gen $level modulations/alphadep-$gen-$level.yoda
        if [ -f modulations/alphadep-$gen-$level.yoda ]; then
            i_input="$i_input modulations/alphadep-$gen-$level.yoda:$gen"
        fi

        ./produce-Rdependence-data.py $gen/${level}/sep-200.log modulations/Rdep-$gen-$level.yoda
        if [ -f modulations/Rdep-$gen-$level.yoda ]; then
            i_input="$i_input modulations/Rdep-$gen-$level.yoda:$gen"
        fi

        ./produce-Qdependence-data.py $gen $level modulations/Qdep-$gen-$level.yoda
        if [ -f modulations/Qdep-$gen-$level.yoda ]; then
            i_input="$i_input modulations/Qdep-$gen-$level.yoda:$gen"
        fi

        ./produce-Rdependence-avg.py $gen $level  modulations/avg-Rdep-$gen-$level.yoda
        if [ -f modulations/avg-Rdep-$gen-$level.yoda ]; then
            a_input="$a_input modulations/avg-Rdep-$gen-$level.yoda:$gen"
        fi

        ./produce-Qdependence-avg.py $gen $level modulations/avg-Qdep-$gen-$level.yoda
        if [ -f modulations/avg-Qdep-$gen-$level.yoda ]; then
            a_input="$a_input modulations/avg-Qdep-$gen-$level.yoda:$gen"
        fi

    done
    # safe-rivet-mkhtml -o plots/alphasdependence -c style-alphasdependence.plot $i_input -t Q=200GeV,R=0.6

    sed "s/@LEVELLABEL@/$level/g" style-modulations.plot > style-modulations-tmp.plot

    
    # do the R modulation
    # i_input=""
    # for gen in $generators; do
    #     message "... $gen"
    # done
    # # safe-rivet-mkhtml -o plots/Rdependence -c style-Rdependence.plot $i_input -t Q=200GeV
    # 
    # 
    # # do the energy modulation
    # # i_input=""
    # for gen in $generators; do
    #     message "... $gen"
    # done
    message ""
    message "... Plot everything"
    message "... input: $i_input"
    # safe-rivet-mkhtml -o plots/Qdependence -c style-Qdependence.plot $i_input -t R=0.6
    safe-rivet-mkhtml -o plots/modulations-${level} -c style-modulations-tmp.plot $i_input -t default_R=0.6,_default_Q=200_GeV
    message "... avg  : $a_input"
    # safe-rivet-mkhtml -o plots/Qdependence -c style-Qdependence.plot $i_input -t R=0.6
    safe-rivet-mkhtml -o plots/averages-${level} -c style-modulations-tmp.plot $a_input -t default_R=0.6,_default_Q=200_GeV

done

# write the "web" info
cat >> $web_global <<EOF
<h3>Generator comparisons</h3>
<table border="1" cellspacing="0" cellpadding="3">
<tr><td>quarks     </td>
    <td><a target="_blank" href="uu-200-R06-allMCs-hadron/MC_LHQG_EE/index.html">hadron</a></td>
    <td><a target="_blank" href="uu-200-R06-allMCs-parton/MC_LHQG_EE/index.html">parton</a></td></tr>
<tr><td>gluons     </td>
    <td><a target="_blank" href="gg-200-R06-allMCs-hadron/MC_LHQG_EE/index.html">hadron</a></td>
    <td><a target="_blank" href="gg-200-R06-allMCs-parton/MC_LHQG_EE/index.html">parton</a></td></tr>
<tr><td>separations</td>
    <td><a target="_blank" href="sep-200-R06-allMCs-hadron/MC_LHQG_EE/index.html">hadron</a></td>
    <td><a target="_blank" href="sep-200-R06-allMCs-parton/MC_LHQG_EE/index.html">parton</a></td></tr>
<tr><td>summary    </td>
    <td><a target="_blank" href="sum-200-R06-allMCs-hadron/separation/index.html">hadron</a></td>
    <td><a target="_blank" href="sum-200-R06-allMCs-parton/separation/index.html">parton</a></td></tr>
<tr><td>variations </td>
    <td><a target="_blank" href="modulations-hadron/index.html">hadron</a></td>
    <td><a target="_blank" href="modulations-parton/index.html">parton</a></td></tr>
<tr><td>Averages   </td>
    <td><a target="_blank" href="averages-hadron/index.html">hadron</a></td>
    <td><a target="_blank" href="averages-parton/index.html">parton</a></td></tr>
</table>
</body>
</html>
EOF

message "all done!"
date | tee -a $logfile
