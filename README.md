lh2015-qg
=========

This repository, currently under development, contains shared software
for the quark-gluon studies done in the context of the [Physics at TeV
colliders workshop](http://phystev.cnrs.fr/) in June 2015.

A wiki page with our progress is here:

http://phystev.cnrs.fr/wiki/2015:groups:sm:qg

This github repository is hosted here:

https://github.com/gsoyez/lh2015-qg


Brief description and Guidelines for the ee study
=================================================

Workflow
--------

- There is a Rivet routine that computes a bunch of observables at a
  few R values (see "Description of the Rivet Routine" below for
  details)

- Consider 2 processes:
   . mu+ mu- -> Z/gamma* -> u ubar
   . mu+ mu- -> Higgs    -> g g

- Each Monte Carlo lives in a folder
    &lt;Generator>-&lt;Version>
  e.g. Pythia-8.1.85 or Herwig-2.7.1

- Each Monte Carlo should produce several result files (YODA):
   . their best central prediction
   . variations of alphas from whatever the "best prediction" has by
     factors of 0.8 and 1.2 [two extra values to be added afterwards]
   . a version without g->qqbar splitting
   . any other variations they think might help understanding what is
     going on
   . By default, run at hadron level

- In each Monte-Carlo folder, there should be a README that tells how
  the results can be generated. This potentially goes with additional
  card files (in a "cards" subfolder if possible).
  E.g. the Sherpa-2.1.1/README file should contain something like
  &lt;this_file.yoda> is obtained by running
     Sherpa NJET:2 ANALYSIS=Rivet -A results/this_file -f cards/Run-hgg.dat

- Consider 5 energies: Q=50, 100, 200, 400, 800 GeV. Variations for
  each Monte-Carlo should only be done at 200 GeV. For the other
  energies, only produce the "best" prediction.

- Naming conventions for the results should follow the following scheme
    < Generator >-< Version >/results/< process >-< Q >[flags].yoda
  where
    . process is either uu or gg
    . the "best" prediction has no flags
    . the alphas variations have flags -alphasx08 -alphasx12
    . the switching off of g->qqbar has flags -nogqq
    . any additional variations comes with a friendly flag (e.g. -nome
      for Matrix-element switched off or -njet0, -parton for
      parton-level studies, ...). These should be briefly described in
      the README
   
Description of what information/plots are extracted of the result files
-----------------------------------------------------------------------

Baseline: Q = 200 GeV, R = 0.6, all Monte Carlo programs optimal

produce a full set of distribution plots for
 . Quark distribution, gluon distribution, separation, integrated separation
 . Pythia variations: noME, nogqq, ...
 . Herwig variations: ...
 . Sherpa variations: ...
 . Vincia variations: noME, ...

Produce some variation plots (one plot for each observable and quality measure)
 . Q = 50, 100, 200, 400, 800 GeV (everything else baseline)
 . R = 0.2, 0.4, 0.6, 0.8, 1.0 (everything else baseline)
 . delta alphas / alphas = -0.2, -0.1, 0.0, +0.1, +0.2 (everything else baseline)

Description of the Rivet Routine
--------------------------------
- Extract all jets (ee-anti-kt(R)) above a given Emin
  JetDefinition jet_def(ee_genkt_algorithm, R, -1.0, WTA_modp_scheme)
  Emin is taken as 0.4*Q

- Core list of shapes to study
    . Generalised angularities:
        kappa=1.0, beta=2.0
        kappa=1.0, beta=1.0
        kappa=1.0, beta=0.5
        kappa=0.0, beta=0.0
        kappa=2.0, beta=0.0
        [use lin and log binning]
    . Thrust for the whole event (thrust axis, lin ang log binning)
    . total multiplicity in 4 different thrust bins:
        T < (5 GeV)/Q
        (5 GeV)/Q < T < 0.1
        0.1 < T < 0.2
        0.2 < T

- Study R=0.2, 0.4, 0.6, 0.8, 1.0


Processes to consider:

Energies [GeV]: (Q=sqrts)
 - 1st batch: 50, 200, 800
 - 2nd batch: 100, 400, 1600, 3200

For the pp study [ !!! OUT OF DATE !!! ]
----------------

Hopefully the same as above with an extra rapidity cut

File contents
-------------

- Shapes.{hh,cc}: contains (FastJet-style) implementation of useful
  jet shapes (only GeneralisedAngularity so far)

- MC_LHQG_EE.cc  Rivet Analysis for the e+e- studies

- MC_LHQG.cc     Rivet Analysis for the pp studies [OUT OF DATE and "bugged"]

- Pythia/Vincia/Herwig/Sherpa directories contain codes and/or yoda files for
  the different generators

- some helper scripts
   . post-process.sh   an overall script that creates the separation tables and the plots
                       This is the script you run to get results out of a git checkout
                       The other files below are secondary.

   . compute-efficiencies.py <quark>.yoda <gluon>.yoda <efficiency>.yoda
      will, given the quark and gluon output, produce
      <efficiency>.yoda with the efficiency histograms and output to
      stdout a table with a bunch of quality measures (see notes in
      tex/ for details) . compute_efficiencies.py

   . get-separation.sh separation_table observable measure
      simple helper that extracts one number (corresponding to a given
      observable and separation measure) from a separation table
      (output of compute-efficiencies.py)

   . produce-separation-plots.py
      creates a yoda file with summary information for a given separation table

Workflow
--------

This describes how to run the Rivet analysis and produce some
plots. For instructions on how to run the different event generators,
see details in the respective generator directories.

If you only want to process yoda files, you can skip steps 2 and 4.

1. make sure you have the proper variables set to run rivet
     source ${rivet_path}/rivetenv.(c)sh

2. build the analysis using
     rivet-buildplugin RivetMC_LHQG.so MC_LHQG.cc MC_LHQG_EE.cc

3. set the current directory in the Rivet analyses path by including . in 
   the RIVET_ANALYSIS_PATH environment variable

4. Run Rivet [producing the yoda files]:
     mkfifo fifo.hepmc
     run_your_generator_output into fifo.hepmc &
     rivet --analysis=MC_LHQG_EE fifo.hepmc -H your_preferred_output.yoda
   For q/g enrichment, run it once for quarks and once for gluons.

5. Produce the separation information and plots by runnung
     ./post-process.sh

   This does a few things:
     - it creates the separation tables and yoda histograms for all the results
     - it rebins the histograms for nicer plots
     - it produces the quark, gluon and separation MC comparison plots
       (parton and hadron level)
     - it generate summary histograms ans plot them
   Check plots.log for details of the run and enjoy the plots in plots/...

Note that individual results can be obtained by individual tools (see
the file description above) and the rivet-mkhtml tool.

     rivet-mkhtml <list of yoda files to plot> -o directory [-c config file]


Results available
-----------------

As of 2015-06-05, 

- Herwig: yoda files provided by Andrzej

- Pythia: card files to run hadron level with a custom tune (with and without ME corrections)
  code to run them awaiting commit
  Yoda files provided by Deepak [some renaming will probably be needed at some point]

- Vincia: card files to run hadron level with a custom tune
  code to run them awaiting commit
  Yoda files provided by Deepak [some renaming will probably be needed at some point]


Plots wanted
------------

the post-process.sh script does the following
   (i) generate the separations
  (ii) do a bit of rebinning for aesthetic reasons
 (iii) produce a bunch of plots

Note that by default existing files are not overwritten. Use FORCE=yes
post-process.sh to overwrite everything.


    

Contributors
============

Gregory Soyez
Jesse Thaler
Andrzej Siodmok
...
