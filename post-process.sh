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
    gluname=${fn/_u_u_/_g_g_}
    if [ -f ${gluname} ]; then
        if [ ! -f ${sepname} ] || [ ! -z $FORCE ]; then
            ./compute-efficiencies.py $fn ${gluname} $sepname > ${sepname%yoda}log
        fi
    fi
done
for fn in Herwig/Herwig7/Hadron_level_Results/*_u_u_*.yoda; do
    sepname=${fn/_u_u_/_sep_}
    gluname=${fn/_u_u_/_g_g_}
    if [ -f ${gluname} ]; then
        if [ ! -f ${sepname} ] || [ ! -z $FORCE ]; then
            ./compute-efficiencies.py $fn ${gluname} $sepname > ${sepname%yoda}log
        fi
    fi
done

echo "  Sherpa"
for fn in Sherpa/results/uu-*.yoda; do
    sepname=${fn/uu/sep}
    gluname=${fn/uu/gg}
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
mkdir -p Herwig/Herwig7/Hadron_level_Rebinned
for fn in Herwig/Herwig7/Hadron_level_Results/*.yoda; do
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
mkdir -p plots
mkdir -p summary

echo "  quarks at 200 GeV, parton level: plots/MCdep-q200-parton" | tee -a plots.log
if [ -d plots/MCdep-q200-parton ] && [ -z $FORCE ] && [ -z $FORCE_PLOTS ]; then
    echo "    plots already made. Delete the directory or run FORCE_PLOTS=yes post-process.sh to regenerate" | tee -a plots.log
else
    rivet-mkhtml Pythia/rebinned/qq-200-parton-mec.yoda:Pythia8 \
                 Pythia/rebinned/qq-200-parton.yoda:Pythia8-noME \
                 Vincia/rebinned/qq-200-parton.yoda:Vincia \
                 Vincia/rebinned/qq-200-parton-nlo.yoda:Vincia-NLO \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_u_u_MG_def_E200.yoda:Herwig++ \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_u_u_MG_E200.yoda:Herwig++-LH15 \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_u_u_MG_dip_E200.yoda:Herwig++-dip \
                 -o plots/MCdep-q200-parton -c MC_LHQG_EE.plot >> plots.log 2>&1
fi

echo "  gluons at 200 GeV, parton level: plots/MCdep-g200-parton" | tee -a plots.log
if [ -d plots/MCdep-g200-parton ] && [ -z $FORCE ] && [ -z $FORCE_PLOTS ]; then
    echo "    plots already made. Delete the directory or run FORCE_PLOTS=yes post-process.sh to regenerate" | tee -a plots.log
else
    rivet-mkhtml Pythia/rebinned/gg-200-parton-mec.yoda:Pythia8 \
                 Pythia/rebinned/gg-200-parton.yoda:Pythia8-noME \
                 Vincia/rebinned/gg-200-parton.yoda:Vincia \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_g_g_MG_def_E200.yoda:Herwig++ \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_g_g_MG_E200.yoda:Herwig++-LH15 \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_g_g_MG_dip_E200.yoda:Herwig++-dip \
                 -o plots/MCdep-g200-parton -c MC_LHQG_EE.plot >> plots.log 2>&1
fi

echo "  separations at 200 GeV, parton level: plots/MCdep-sep200-parton" | tee -a plots.log
if [ -d plots/MCdep-sep200-parton ] && [ -z $FORCE ] && [ -z $FORCE_PLOTS ]; then
    echo "    plots already made. Delete the directory or run FORCE_PLOTS=yes post-process.sh to regenerate" | tee -a plots.log
else
    rivet-mkhtml Pythia/rebinned/sep-200-parton-mec.yoda:Pythia8 \
                 Pythia/rebinned/sep-200-parton.yoda:Pythia8-noME \
                 Vincia/rebinned/sep-200-parton.yoda:Vincia \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_sep_MG_def_E200.yoda:Herwig++ \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_sep_MG_E200.yoda:Herwig++-LH15 \
                 Herwig/Herwig7/Parton_level_Rebinned/LEP-Matchbox_mum_mup_to_sep_MG_dip_E200.yoda:Herwig++-dip \
                 -o plots/MCdep-sep200-parton -c MC_LHQG_EE.plot >> plots.log 2>&1
fi

for sqrts in 200 800; do 

    echo "  quarks at ${sqrts} GeV, hadron level: plots/MCdep-q${sqrts}-hadron" | tee -a plots.log
    if [ -d plots/MCdep-q${sqrts}-hadron ] && [ -z $FORCE ] && [ -z $FORCE_PLOTS ]; then
        echo "    plots already made. Delete the directory or run FORCE_PLOTS=yes post-process.sh to regenerate" | tee -a plots.log
    else
        rivet-mkhtml Pythia/rebinned/qq-${sqrts}-hadron-mec.yoda:Pythia8 \
                     Pythia/rebinned/qq-${sqrts}-hadron.yoda:Pythia8-noME \
                     Vincia/rebinned/qq-${sqrts}-hadron.yoda:Vincia \
                     Vincia/rebinned/qq-${sqrts}-hadron-nlo.yoda:Vincia-NLO \
                     Sherpa/rebinned/uu-${sqrts}-njet0.yoda:Sherpa-Njet0 \
                     Sherpa/rebinned/uu-${sqrts}-njet2.yoda:Sherpa-Njet2 \
                     Herwig/Herwig7/Hadron_level_Rebinned/LEP-Matchbox_mum_mup_to_u_u_MG_def_had_E${sqrts}.yoda:Herwig++ \
                     Herwig/Herwig7/Hadron_level_Rebinned/LEP-Matchbox_mum_mup_to_u_u_MG_dip_def_had_E${sqrts}.yoda:Herwig++-dip \
                     -o plots/MCdep-q${sqrts}-hadron -c MC_LHQG_EE.plot >> plots.log 2>&1
    fi

    echo "  gluons at ${sqrts} GeV, hadron level: plots/MCdep-g${sqrts}-hadron" | tee -a plots.log
    if [ -d plots/MCdep-g${sqrts}-hadron ] && [ -z $FORCE ] && [ -z $FORCE_PLOTS ]; then
        echo "    plots already made. Delete the directory or run FORCE_PLOTS=yes post-process.sh to regenerate" | tee -a plots.log
    else
        rivet-mkhtml Pythia/rebinned/gg-${sqrts}-hadron-mec.yoda:Pythia8 \
                     Pythia/rebinned/gg-${sqrts}-hadron.yoda:Pythia8-noME \
                     Vincia/rebinned/gg-${sqrts}-hadron.yoda:Vincia \
                     Sherpa/rebinned/gg-${sqrts}-njet0.yoda:Sherpa-Njet0 \
                     Sherpa/rebinned/gg-${sqrts}-njet2.yoda:Sherpa-Njet2 \
                     Herwig/Herwig7/Hadron_level_Rebinned/LEP-Matchbox_mum_mup_to_g_g_MG_def_had_E${sqrts}.yoda:Herwig++ \
                     Herwig/Herwig7/Hadron_level_Rebinned/LEP-Matchbox_mum_mup_to_g_g_MG_dip_def_had_E${sqrts}.yoda:Herwig++-dip \
                     -o plots/MCdep-g${sqrts}-hadron -c MC_LHQG_EE.plot >> plots.log 2>&1
    fi

    echo "  separations at ${sqrts} GeV, hadron level: plots/MCdep-sep${sqrts}-hadron" | tee -a plots.log
    if [ -d plots/MCdep-sep${sqrts}-hadron ] && [ -z $FORCE ] && [ -z $FORCE_PLOTS ]; then
        echo "    plots already made. Delete the directory or run FORCE_PLOTS=yes post-process.sh to regenerate" | tee -a plots.log
    else
        rivet-mkhtml Pythia/rebinned/sep-${sqrts}-hadron-mec.yoda:Pythia8 \
                     Pythia/rebinned/sep-${sqrts}-hadron.yoda:Pythia8-noME \
                     Vincia/rebinned/sep-${sqrts}-hadron.yoda:Vincia \
                     Sherpa/rebinned/sep-${sqrts}-njet0.yoda:Sherpa-Njet0 \
                     Sherpa/rebinned/sep-${sqrts}-njet2.yoda:Sherpa-Njet2 \
                     Herwig/Herwig7/Hadron_level_Rebinned/LEP-Matchbox_mum_mup_to_sep_MG_def_had_E${sqrts}.yoda:Herwig++ \
                     Herwig/Herwig7/Hadron_level_Rebinned/LEP-Matchbox_mum_mup_to_sep_MG_dip_def_had_E${sqrts}.yoda:Herwig++-dip \
                     -o plots/MCdep-sep${sqrts}-hadron -c MC_LHQG_EE.plot >> plots.log 2>&1
    fi


    # produce efficiency plots
    echo "  efficiency tables and plots at ${sqrts} GeV"

    ./produce-separation-plots.py Pythia/results/sep-${sqrts}-hadron-mec.log summary/Pythia-hadron-mec-${sqrts}.yoda
    ./produce-separation-plots.py Pythia/results/sep-${sqrts}-hadron.log summary/Pythia-hadron-${sqrts}.yoda
    ./produce-separation-plots.py Vincia/results/sep-${sqrts}-hadron.log summary/Vincia-hadron-${sqrts}.yoda
    ./produce-separation-plots.py Sherpa/results/sep-${sqrts}-njet0.log summary/Sherpa-hadron-njet0-${sqrts}.yoda
    ./produce-separation-plots.py Sherpa/results/sep-${sqrts}-njet2.log summary/Sherpa-hadron-njet2-${sqrts}.yoda
    ./produce-separation-plots.py Herwig/Herwig7/Hadron_level_Results/LEP-Matchbox_mum_mup_to_sep_MG_def_had_E${sqrts}.log summary/Herwig-hadron-${sqrts}.yoda
    ./produce-separation-plots.py Herwig/Herwig7/Hadron_level_Results/LEP-Matchbox_mum_mup_to_sep_MG_dip_def_had_E${sqrts}.log summary/Herwig-hadron-dip-${sqrts}.yoda
    rivet-mkhtml -c separation.plot -o plots/summary-${sqrts} \
                 summary/Pythia-hadron-mec-${sqrts}.yoda:Pythia \
                 summary/Pythia-hadron-${sqrts}.yoda:Pythia-noME \
                 summary/Vincia-hadron-${sqrts}.yoda:Vincia \
                 summary/Sherpa-hadron-njet0-${sqrts}.yoda:Sherpa-njet0 \
                 summary/Sherpa-hadron-njet2-${sqrts}.yoda:Sherpa-njet2 \
                 summary/Herwig-hadron-${sqrts}.yoda:Herwig \
                 summary/Herwig-hadron-dip-${sqrts}.yoda:Herwig-dip \
                 >> plots.log 2>&1

done
    
echo "You're all set!"
