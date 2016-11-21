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
logfile=post-process-pp.log
date > $logfile

# list of included generators 
desired_generators="Pythia-8215 Vincia-2001"


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
        echo $@
        rivet-mkhtml $@ >> logfile 2>&1
    fi
}

#----------------------------------------------------------------------
# generic generators
message ""
message "Building the list of supported generators"
generators=""
for gen in $desired_generators; do
    if [ -d $gen/lhc/hadron ]; then
        generators="$generators $gen"
    fi
done
message "... Will work with $generators"

# while we go on with all the plots and build of the extra info, we
# shall make a snall webpage to ease naviogation through everything
if [ ! -d plots ]; then
    mkdir plots
fi
if [ ! -d plots/lhc ]; then
    mkdir plots/lhc
fi
message "Starting summary webpage as plots/lhc/index.html"
web_global="plots/lhc/index.html"

cat  > $web_global <<EOF
<html>
<head>
<title>LHC Quark-gluon studies for Les-Houches 2015</title>
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
<body><h2>LHC Quark-gluon studies for Les-Houches 2015</h2>
EOF

#------------------------------------------------------------------------
# compute separations: note that here we do compute separations
# between the dijet and Z+jet samples
message ""
message "Computing separations"
for gen in $generators; do
    for level in hadron parton; do
        message "... $gen --- $level"
        for fn in $gen/lhc/${level}/zjet*.yoda; do
            dijetname=${fn/zjet/dijet}
            if [ -f ${dijetname} ]; then
                sepname=${fn/zjet/sep}
                if [ ! -f ${sepname} ] || [ ! -z $FORCE ]; then
                    logname=${sepname%yoda}log
                    # check if the files differ
                    if diff $fn ${dijetname} > /dev/null ; then
                        echo "...... WARNING: ${fn} $dijetname HAVE THE SAME CONTENTS"
                    fi
                    # do the computation
                    ./compute-efficiencies-pp-new.py $fn ${dijetname} $sepname > $logname
                    ./produce-separation-data-pp.py ${logname} ${sepname/sep/sum}
                fi
            fi
        done
    done
done


#------------------------------------------------------------------------
# make plots for each of the generators: NOT DONE

#------------------------------------------------------------------------
# do the MC comparison on the baseline
#
# Note that our regular expression GA.*_Q100_R4 automatically includes
# the mMDT results (as well as the log-scale ones)
message ""
message "Plots for generator comparison at 100 GeV, R=0.4"
for level in hadron; do
    message "... $level"
    dijet_input=""
    zjet_input=""
    sep_input=""
    sum_input=""
    mkdir -p post-process-tmpfiles/dijet
    mkdir -p post-process-tmpfiles/zjet
    mkdir -p post-process-tmpfiles/sep
    mkdir -p post-process-tmpfiles/sum
    for gen in $generators; do
        if [ -f $gen/lhc/${level}/dijet.yoda ]; then
           yodacnv $gen/lhc/${level}/dijet.yoda  -m "GA.*_Q100_R4" post-process-tmpfiles/dijet/${gen}.yoda
           dijet_input="$dijet_input post-process-tmpfiles/dijet/${gen}.yoda"
        fi
        if [ -f $gen/lhc/${level}/zjet.yoda ]; then
           yodacnv $gen/lhc/${level}/zjet.yoda  -m "GA.*_Q100_R4" post-process-tmpfiles/zjet/${gen}.yoda
           zjet_input="$zjet_input post-process-tmpfiles/zjet/${gen}.yoda "
        fi
        if [ -f $gen/lhc/${level}/sep.yoda ]; then
           yodacnv $gen/lhc/${level}/sep.yoda  -m "GA.*_Q100_R4" post-process-tmpfiles/sep/${gen}.yoda
           sep_input="$sep_input post-process-tmpfiles/sep/${gen}.yoda "
        fi
        if [ -f $gen/lhc/${level}/sum.yoda ]; then
           yodacnv $gen/lhc/${level}/sum.yoda post-process-tmpfiles/sum/${gen}.yoda
           sum_input="$sum_input post-process-tmpfiles/sum/${gen}.yoda "
        fi
    done
    message "... plot dijet: $dijet_input"    
    message "... plot zjet : $zjet_input"
    message "... plot sep  : $sep_input"
    message "... plot sum  : $sum_input"

    # prepare the style file with the appropriate labels
        
    # do the plots
    sed "s/@GENLABEL@/dijet, $level, Q=100GeV/g;s/@PROC@/dijet/g" style-variations-pp.plot > style-variations-tmp.plot
    safe-rivet-mkhtml -o plots/lhc/dijet-100-R04-allMCs-${level} $dijet_input -c style-variations-tmp.plot -t Q=100GeV,R=0.4
    sed "s/@GENLABEL@/Z+jet, $level, Q=100GeV/g;s/@PROC@/Zjet/g" style-variations-pp.plot > style-variations-tmp.plot
    safe-rivet-mkhtml -o plots/lhc/zjet-100-R04-allMCs-${level}  $zjet_input  -c style-variations-tmp.plot -t Q=100GeV,R=0.4
    sed "s/@GENLABEL@/separation, $level, Q=100GeV/g;s/@PROC@/Zjet/g" style-variations-pp.plot > style-variations-tmp.plot
    safe-rivet-mkhtml -o plots/lhc/sep-100-R04-allMCs-${level}  $sep_input  -c style-variations-tmp.plot -t Q=100GeV,R=0.4
    sed "s/@GENLABEL@/$level, Q=100GeV, R=0.4/g;s/@PROC@/Zjet/g" style-separation.plot > style-separation-tmp.plot
    safe-rivet-mkhtml -o plots/lhc/sum-100-R04-allMCs-${level}  $sum_input  -c style-separation-tmp.plot -t Q=100GeV,R=0.4

    rm -Rf post-process-tmpfiles/*
done

#----------------------------------------------------------------------
# do the modulations
mkdir -p modulations/lhc
message ""
message "Plots of the Q and R modulation for individual generators at Q=100 GeV, R=0.4"
for level in hadron parton; do
    message "... $level"
    i_input=""
    a_input=""
    for gen in $generators; do
        message "... $gen"

        # skip if the base files are not present
        if [ ! -f $gen/lhc/${level}/sep.log ]; then continue; fi
       
#         ./produce-alphadependence-data.py $gen $level modulations/alphadep-$gen-$level.yoda
#         if [ -f modulations/alphadep-$gen-$level.yoda ]; then
#             i_input="$i_input modulations/alphadep-$gen-$level.yoda:$gen"
#         fi

        ./produce-Rdependence-data-pp.py $gen/lhc/${level}/sep.log modulations/lhc/Rdep-$gen-$level.yoda
        if [ -f modulations/lhc/Rdep-$gen-$level.yoda ]; then
            i_input="$i_input modulations/lhc/Rdep-$gen-$level.yoda:$gen"
        fi

        ./produce-Qdependence-data-pp.py $gen/lhc/${level}/sep.log modulations/lhc/Qdep-$gen-$level.yoda
        if [ -f modulations/lhc/Qdep-$gen-$level.yoda ]; then
            i_input="$i_input modulations/lhc/Qdep-$gen-$level.yoda:$gen"
        fi

#         ./produce-Rdependence-avg.py $gen $level  modulations/avg-Rdep-$gen-$level.yoda
#         if [ -f modulations/avg-Rdep-$gen-$level.yoda ]; then
#             a_input="$a_input modulations/avg-Rdep-$gen-$level.yoda:$gen"
#         fi
# 
#         ./produce-Qdependence-avg.py $gen $level modulations/avg-Qdep-$gen-$level.yoda
#         if [ -f modulations/avg-Qdep-$gen-$level.yoda ]; then
#             a_input="$a_input modulations/avg-Qdep-$gen-$level.yoda:$gen"
#         fi

    done
    # safe-rivet-mkhtml -o plots/alphasdependence -c style-alphasdependence.plot $i_input -t Q=200GeV,R=0.6

    sed "s/@LEVELLABEL@/$level/g" style-modulations.plot > style-modulations-tmp.plot

    message ""
    message "... Plot everything"
    message "... input: $i_input"
    safe-rivet-mkhtml -o plots/lhc/modulations-${level} -c style-modulations-tmp.plot $i_input -t default_R=0.4,_default_Q=100_GeV
#     message "... avg  : $a_input"
#     # safe-rivet-mkhtml -o plots/Qdependence -c style-Qdependence.plot $i_input -t R=0.6
#     safe-rivet-mkhtml -o plots/averages-${level} -c style-modulations-tmp.plot $a_input -t default_R=0.6,_default_Q=200_GeV
# 
done

# write the "web" info
cat >> $web_global <<EOF
<h3>Generator comparisons</h3>
<table border="1" cellspacing="0" cellpadding="3">
<tr><td>dijet     </td>
    <td><a target="_blank" href="dijet-100-R04-allMCs-hadron/MC_LHQG_dijet/index.html">hadron</a></td></tr>
<tr><td>Z+jet     </td>
    <td><a target="_blank" href="zjet-100-R04-allMCs-hadron/MC_LHQG_Zjet/index.html">hadron</a></td></tr>
<tr><td>Separation</td>
    <td><a target="_blank" href="sep-100-R04-allMCs-hadron/MC_LHQG_Zjet/index.html">hadron</a></td></tr>
<tr><td>Summary   </td>
    <td><a target="_blank" href="sum-100-R04-allMCs-hadron/separation/index.html">hadron</a></td></tr>
<tr><td>variations </td>
    <td><a target="_blank" href="modulations-hadron/index.html">hadron</a></td></tr>
</table>
</body>
</html>
EOF

message "all done!"
date | tee -a $logfile
