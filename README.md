lh2015-qg
=========

This repository, currently under development, contains shared software
for the quark-gluon studies done in the context of the [Physics at TeV
colliders workshop](http://phystev.cnrs.fr/) in June 2015.

A wiki page with our progress is here:

http://phystev.cnrs.fr/wiki/2015:groups:sm:qg

This github repository is hosted here:

https://github.com/gsoyez/lh2015-qg


Brief description
=================

For the ee study
----------------

- Extract all jets (ee-anti-kt(R)) above a given Emin
  JetDefinition jet_def(ee_genkt_algorithm, R, -1.0, WTA_modp_scheme)

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

- Study R=0.3, 0.6, 0.9

Parameters:
 - Emin [default 0.4 sqrts]

Processes to consider:
 - Z/gamma* to uubar [charm and bottom later]
 - Higgs to gg

Energies [GeV]: (Q=sqrts)
 - 1st batch: 50, 200, 800
 - 2nd batch: 100, 500, 1600, 3200

For the pp study [ !!! OUT OF DATE !!! ]
----------------

Hopefully the same as above with an extra rapidity cut

File contents
-------------

- Shapes.{hh,cc}: contains (FastJet-style) implementation of useful
  jet shapes (only GeneralisedAngularity so far)

- MC_LHQG_EE.cc  Rivet Analysis for the e+e- studies

- MC_LHQG.cc     Rivet Analysis for the pp studies [OUT OF DATE and "bugged"]

- Pythia/Vincia/Herwig directories contain codes and/or yoda files for
  the different generators


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

5. To produce efficiency information, run
     ./compute-efficiencies.py <quark>.yoda <gluon>.yoda <efficiency>.yoda
   which will, given the quark and gluon output, produce
   <efficiency>.yoda with the efficiency histograms and output to
   stdout a table with a bunch of quality measures (see notes in tex/
   for details)

6. create the plots [from the yoda files] running
     rivet-mkhtml <list of yoda files to plot>


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
...
