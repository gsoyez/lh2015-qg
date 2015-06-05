#!/bin/bash
#
# prepare results and plots

# generate separations
echo "Computing separations"
echo "  Pythia"
for fn in Pythia/results/qq*.yoda; do
    sepname=${fn/qq/sep}
    gluname=${fn/qq/gg}
    if [ -f ${gluname} ]; then
        if [ ! -f ${sepname} ] || [ ! -z $FORCE ]; then
            ./compute-efficiencies.py $fn ${gluname} $sepname > ${sepname%yoda}log
        fi
    fi
done

echo "  Vincia"
for fn in Vincia/results/qq*.yoda; do
    sepname=${fn/qq/sep}
    gluname=${fn/qq/gg}
    if [ -f ${gluname} ]; then
        if [ ! -f ${sepname} ] || [ ! -z $FORCE ]; then
            ./compute-efficiencies.py $fn ${gluname} $sepname > ${sepname%yoda}log
        fi
    fi
done

echo "  Herwig"
for fn in Herwig/Herwig7/Parton_level_Results/*_u_u_*.yoda; do
    sepname=${fn/_u_u_/_sep_}
    gluname=${fn/_g_g_/_sep_}
    if [ -f ${gluname} ]; then
        if [ ! -f ${sepname} ] || [ ! -z $FORCE ]; then
            ./compute-efficiencies.py $fn ${gluname} $sepname > ${sepname%yoda}log
        fi
    fi

done

echo "  Sherpa"
for fn in Sherpa/results/q*.yoda; do
    sepname=${fn/q/sep}
    gluname=${fn/q/g}
    if [ -f ${gluname} ]; then
        if [ ! -f ${sepname} ] || [ ! -z $FORCE ]; then
            ./compute-efficiencies.py $fn ${gluname} $sepname > ${sepname%yoda}log
        fi
    fi
done

# rebin pythia, vincia, herwig
echo "Rebinning"
echo "  Pythia"
mkdir -p Pythia/rebinned
for fn in Pythia/results/*.yoda; do
    outname=${fn/results/rebinned} 
    if [ ! -f ${outname} ] || [ ! -z $FORCE ]; then
        ./yoda-rebin.py $fn $outname | grep -v "vs."
    fi
done

echo "  Vincia"
mkdir -p Vincia/rebinned
for fn in Vincia/results/*.yoda; do
    outname=${fn/results/rebinned} 
    if [ ! -f ${outname} ] || [ ! -z $FORCE ]; then
        ./yoda-rebin.py $fn $outname | grep -v "vs."
    fi
done

echo "  Herwig"
mkdir -p Herwig/Herwig7/Parton_level_Rebinned
for fn in Herwig/Herwig7/Parton_level_Results/*.yoda; do
    outname=${fn/Results/Rebinned}
    if [ ! -f ${outname} ] || [ ! -z $FORCE ]; then
        ./yoda-rebin.py $fn $outname | grep -v "vs."
    fi
done

echo "  Sherpa"
mkdir -p Sherpa/rebinned
for fn in Sherpa/results/*.yoda; do
    outname=${fn/results/rebinned}
    if [ ! -f ${outname} ] || [ ! -z $FORCE ]; then
        ./yoda-rebin.py $fn $outname | grep -v "vs."
    fi
done

# produce plots
echo "Producing plots (logging in plots.log)"
date > plots.log

echo "  quarks, parton level: plots/MCdep-q200-parton" | tee -a plots.log
if [ -d plots/MCdep-q200-parton ] && [ -z $FORCE ]; then
    echo "    plots already made. Delete the directory or run FORCE=yes post-process.sh to regenerate" | tee -a plots.log
else
    rivet-mkhtml Pythia/rebinned/qq-200-parton-mec.yoda:Pythia8 \
                 Pythia/rebinned/qq-200-parton.yoda:Pythia8-noME \
                 Vincia/rebinned/qq-200-parton.yoda:Vincia \
                 Vincia/rebinned/qq-200-parton-nlo.yoda:Vincia-NLO \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_u_u_MG_E200.yoda:Herwig++ \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_u_u_MG_dip_E200.yoda:Herwig++-dip \
                 -o plots/MCdep-q200-parton >> plots.log 2>&1
fi

echo "  gluons, parton level: plots/MCdep-g200-parton" | tee -a plots.log
if [ -d plots/MCdep-g200-parton ] && [ -z $FORCE ]; then
    echo "    plots already made. Delete the directory or run FORCE=yes post-process.sh to regenerate" | tee -a plots.log
else
    rivet-mkhtml Pythia/rebinned/gg-200-parton-mec.yoda:Pythia8 \
                 Pythia/rebinned/gg-200-parton.yoda:Pythia8-noME \
                 Vincia/rebinned/gg-200-parton.yoda:Vincia \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_g_g_MG_E200.yoda:Herwig++ \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_g_g_MG_dip_E200.yoda:Herwig++-dip \
                 -o plots/MCdep-g200-parton >> plots.log 2>&1
fi

echo "  separations, parton level: plots/MCdep-sep200-parton" | tee -a plots.log
if [ -d plots/MCdep-sep200-parton ] && [ -z $FORCE ]; then
    echo "    plots already made. Delete the directory or run FORCE=yes post-process.sh to regenerate" | tee -a plots.log
else
    rivet-mkhtml Pythia/rebinned/sep-200-parton-mec.yoda:Pythia8 \
                 Pythia/rebinned/sep-200-parton.yoda:Pythia8-noME \
                 Vincia/rebinned/sep-200-parton.yoda:Vincia \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_sep_MG_E200.yoda:Herwig++ \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_sep_MG_dip_E200.yoda:Herwig++-dip \
                 -o plots/MCdep-sep200-parton >> plots.log 2>&1
fi


echo "  quarks, hadron level: plots/MCdep-q200-hadron" | tee -a plots.log
if [ -d plots/MCdep-q200-hadron ] && [ -z $FORCE ]; then
    echo "    plots already made. Delete the directory or run FORCE=yes post-process.sh to regenerate" | tee -a plots.log
else
    rivet-mkhtml Pythia/rebinned/qq-200-hadron-mec.yoda:Pythia8 \
                 Pythia/rebinned/qq-200-hadron.yoda:Pythia8-noME \
                 Vincia/rebinned/qq-200-hadron.yoda:Vincia \
                 Vincia/rebinned/qq-200-hadron-nlo.yoda:Vincia-NLO \
                 Sherpa/rebinned/q200-njet0.yoda:Sherpa-Njet0 \
                 Sherpa/rebinned/q200-njet2.yoda:Sherpa-Njet2 \
                 -o plots/MCdep-q200-hadron >> plots.log 2>&1
fi

echo "  gluons, hadron level: plots/MCdep-g200-hadron" | tee -a plots.log
if [ -d plots/MCdep-g200-hadron ] && [ -z $FORCE ]; then
    echo "    plots already made. Delete the directory or run FORCE=yes post-process.sh to regenerate" | tee -a plots.log
else
    rivet-mkhtml Pythia/rebinned/gg-200-hadron-mec.yoda:Pythia8 \
                 Pythia/rebinned/gg-200-hadron.yoda:Pythia8-noME \
                 Vincia/rebinned/gg-200-hadron.yoda:Vincia \
                 Sherpa/rebinned/g200-njet0.yoda:Sherpa-Njet0 \
                 Sherpa/rebinned/g200-njet2.yoda:Sherpa-Njet2 \
                 -o plots/MCdep-g200-hadron >> plots.log 2>&1
fi

echo "  separations, hadron level: plots/MCdep-sep200-hadron" | tee -a plots.log
if [ -d plots/MCdep-sep200-hadron ] && [ -z $FORCE ]; then
    echo "    plots already made. Delete the directory or run FORCE=yes post-process.sh to regenerate" | tee -a plots.log
else
    rivet-mkhtml Pythia/rebinned/sep-200-hadron-mec.yoda:Pythia8 \
                 Pythia/rebinned/sep-200-hadron.yoda:Pythia8-noME \
                 Vincia/rebinned/sep-200-hadron.yoda:Vincia \
                 Sherpa/rebinned/sep200-njet0.yoda:Sherpa-Njet0 \
                 Sherpa/rebinned/sep200-njet2.yoda:Sherpa-Njet2 \
                 -o plots/MCdep-sep200-hadron >> plots.log 2>&1
fi


echo "You're all set!"
