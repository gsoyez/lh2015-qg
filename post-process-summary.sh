#!/bin/bash
#

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


# custom rules for summary plots
safe-rivet-mkhtml -o plots/sum-200-R06-Pythia-8205 \
        Pythia-8205/results/sum-200.yoda:Default:'LineColor=black' \
        Pythia-8205/results/sum-200-nogqq.yoda:No_gqq:'LineColor=orange' \
        Pythia-8205/results/sum-200-nome.yoda:No_ME:'LineColor=blue' \
        Pythia-8205/results/sum-200-norec.yoda:No_Rec:'LineColor=blue':'LineStyle=dashed' \
        Pythia-8205/results/sum-200-nohad.yoda:Parton:'LineColor={[rgb]{0.0,0.8,0.0}}' -c style-separation.plot -t $gen,Q=200GeV,R=0.6

safe-rivet-mkhtml -o plots/sum-200-R06-Vincia-1201 \
        Vincia-1201/results/sum-200.yoda:Default_LO:'LineColor=black' \
        Vincia-1201/results/sum-200-noqgg.yoda:No_gqq:'LineColor=orange' \
        Vincia-1201/results/sum-200-nome.yoda:No_ME:'LineColor=blue' \
        Vincia-1201/results/sum-200-norec.yoda:No_Rec:'LineColor=blue':'LineStyle=dashed' \
        Vincia-1201/results/sum-200-muq.yoda:muq:'LineColor=red' \
        Vincia-1201/results/sum-200-nohad.yoda:Parton:'LineColor={[rgb]{0.0,0.8,0.0}}':'LineStyle=solid' -c style-separation.plot -t $gen,Q=200GeV,R=0.6

safe-rivet-mkhtml -o plots/sum-200-R06-Sherpa-2.1.1 \
        Sherpa-2.1.1/results/sum-200.yoda:Default:'LineColor=black' \
        Sherpa-2.1.1/results/sum-200-njet1-noqq.yoda:No_gqq:'LineColor=orange' \
        Sherpa-2.1.1/results/sum-200-njet0.yoda:No_ME:'LineColor=blue' \
        Sherpa-2.1.1/results/sum-200-njet1.yoda:Njet1:'LineColor=blue':'LineStyle=dashed' \
        Sherpa-2.1.1/results/sum-200-parton.yoda:Parton:'LineColor={[rgb]{0.0,0.8,0.0}}' -c style-separation.plot -t $gen,Q=200GeV,R=0.6

safe-rivet-mkhtml -o plots/sum-200-R06-Herwig-2_7_1 \
        Herwig-2_7_1/results/sum-200.yoda:Default:'LineColor=black' \
        Herwig-2_7_1/results/sum-200-nogqq.yoda:No_gqq:'LineColor=orange' \
        Herwig-2_7_1/results/sum-200-dipole.yoda:Dipole:'LineColor=black':'LineStyle=dashed' \
        Herwig-2_7_1/results/sum-200-nocr.yoda:No_CR:'LineColor=red' \
        Herwig-2_7_1/results/sum-200-dipoleNoCR.yoda:Dipole_noCR:'LineColor=red':'LineStyle=dashed' \
        Herwig-2_7_1/results/sum-200-parton.yoda:Parton:'LineColor={[rgb]{0.0,0.8,0.0}}':'LineStyle=solid' -c style-separation.plot -t $gen,Q=200GeV,R=0.6