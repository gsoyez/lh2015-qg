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

For the pp study
----------------

- Extract jets (anti-kt(R)) above a given ptmin and within a rapmax acceptance
  Only consider the leading jet (provided it passes the cuts)
  JetDefinition jet_def(antikt_algorithm, R, WTA_pt_scheme)

- Core list of shapes to study
   fastjet_shaoes::GeneralisedAngularity(1.0, 2.0, R); // angularity (mass)
   fastjet_shaoes::GeneralisedAngularity(1.0, 1.0, R); // angularity (girth)
   fastjet_shaoes::GeneralisedAngularity(1.0, 0.5, R); // angularity (smaller supposedly more efficient)
   fastjet_shaoes::GeneralisedAngularity(0.0, 0.0, R); // multiplicity
   fastjet_shaoes::GeneralisedAngularity(2.0, 0.0, R); // pTD^2

- just look at the distribution of the shapes
  initial guess for the ranges:
    GeneralisedAngularity(1.0, 2.0): from 0 to 1 in bins 0.001
    GeneralisedAngularity(1.0, 1.0): from 0 to 1 in bins 0.001
    GeneralisedAngularity(1.0, 0.5): from 0 to 1 in bins 0.001
    GeneralisedAngularity(0.0, 0.0): from -0.5 to 300.5 in bins of 1 
    GeneralisedAngularity(2.0, 0.0): from 0 to 1 in bins 0.001


Parameters:
 - R [default 0.6]
 - ptmin [default 400]
 - rapmax [default 2.5]

For the ee study
----------------

  compared to pp, we have to use e+e- coordinates. This changes the
  jet definition and the coordinated for the angularities

- Extract all jets (ee-anti-kt(R)) above a given Emin
  JetDefinition jet_def(ee_genkt_algorithm, R, -1.0, WTA_modp_scheme)

- Core list of shapes to study
   fastjet_shaoes::GeneralisedAngularity(1.0, 2.0, R, E_theta); // angularity (mass)
   fastjet_shaoes::GeneralisedAngularity(1.0, 1.0, R, E_theta); // angularity (girth)
   fastjet_shaoes::GeneralisedAngularity(1.0, 0.5, R, E_theta); // angularity (smaller supposedly more efficient)
   fastjet_shaoes::GeneralisedAngularity(0.0, 0.0, R, E_theta); // multiplicity
   fastjet_shaoes::GeneralisedAngularity(2.0, 0.0, R, E_theta); // pTD^2

- just look at the distribution of the shapes
  initial guess for the ranges:
    GeneralisedAngularity(1.0, 2.0): from 0 to 1 in bins 0.001
    GeneralisedAngularity(1.0, 1.0): from 0 to 1 in bins 0.001
    GeneralisedAngularity(1.0, 0.5): from 0 to 1 in bins 0.001
    GeneralisedAngularity(0.0, 0.0): from -0.5 to 300.5 in bins of 1 
    GeneralisedAngularity(2.0, 0.0): from 0 to 1 in bins 0.001

Parameters:
 - R [default 0.6]
 - Emin [default 400 for asqrts=1 TeV]

Processes to consider:
 - Zprime to qqbar [or separate Zprime to uds and Zprime to b]
 - Higgs to gg
 - Do we want a common object decaying either to uds, or to b or to g?
   Is there sth that can be common to Pythia, Vincia and Herwig++]

Energies [GeV]:
 - 1st batch: 50, 200, 1000
 - 2nd batch: 100, 500, 2000, 5000

File contents
-------------

- Shapes.{hh,cc}: contains (FastJet-style) implementation of useful
  jet shapes (only GeneralisedAngularity so far)

- MC_LHQG_EE.cc  Rivet Analysis for the e+e- studies

- MC_LHQG.cc     Rivet Analysis for the pp studies

Getting Rivet to run
--------------------

- source ${rivet_path}/rivetenv.(c)sh
- build the analysis using
   rivet-buildplugin RivetMC_LHQG.so MC_LHQG.cc MC_LHQG_EE.cc
- set the current directory in the Rivet analyses path by including . in 
  the RIVET_ANALYSIS_PATH environment variable

- Running Rivet:
   > mkfifo fifo.hepmc
   > my-generator --num-events=500000 --hepmc-output=fifo.hepmc &
   > rivet --analysis=ANALYSIS_NAME fifo.hepmc -H output.yoda

- create the plots
   > rivet-mkhtml output1.yoda output2.yoda ...

Contributors
============

Gregory Soyez
Jesse Thaler
...
