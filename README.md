lh2015-qg
=========

This repository, currently under development, contains shared software
for the quark-gluon studies done in the context of the [Physics at TeV
colliders workshop](http://phystev.cnrs.fr/) in June 2015.

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

File contents
=============

- Shapes.{hh,cc}: contains (FastJet-style) implementation of useful
  jet shapes (only GeneralisedAngularity so far)

Contributors
============

Gregory Soyez
Jesse Thaler

