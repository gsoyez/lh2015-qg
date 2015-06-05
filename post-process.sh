#!/bin/bash
#
# prepare results and plots

# generate separations
echo "Computing separations"
echo "  Pythia"
for fn in Pythia/results/qq*.yoda; do
    outname=${fn/qq/sep}
    if [ ! -f ${outname} ] || [ ! -z $FORCE ]; then
        ./compute-efficiencies.py $fn ${fn/qq/gg} $outname > ${outname%yoda}log
    fi
done

echo "  Vincia"
for fn in Vincia/results/qq*.yoda; do
    outname=${fn/qq/sep}
    if [ ! -f ${outname} ] || [ ! -z $FORCE ]; then
        ./compute-efficiencies.py $fn ${fn/qq/gg} $outname > ${outname%yoda}log
    fi
done

echo "  Herwig"
for fn in Herwig/Herwig7/Parton_level_Results/*_u_u_*.yoda; do
    outname=${fn/_u_u_/_sep_}
    if [ ! -f ${outname} ] || [ ! -z $FORCE ]; then
        ./compute-efficiencies.py $fn ${fn/_u_u_/_g_g_} $outname > ${outname%yoda}log
    fi
done

# rebin pythia, vincia, herwig
echo "Rebinning"
echo "  Pythia"
for fn in Pythia/results/*.yoda; do
    outname=${fn/results/rebinned} 
    if [ ! -f ${outname} ] || [ ! -z $FORCE ]; then
        ./yoda-rebin.py $fn $outname | grep -v "vs."
    fi
done

echo "  Vincia"
for fn in Vincia/results/*.yoda; do
    outname=${fn/results/rebinned} 
    if [ ! -f ${outname} ] || [ ! -z $FORCE ]; then
        ./yoda-rebin.py $fn $outname | grep -v "vs."
    fi
done

echo "  Herwig"
for fn in Herwig/Herwig7/Parton_level_Results/*.yoda; do
    outname=${fn/Results/Rebinned}
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

echo "You're all set!"
