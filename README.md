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
   fastjet_shaoes::GeneralisedAngularity(1.0, 2.0); // angularity (mass)
   fastjet_shaoes::GeneralisedAngularity(1.0, 1.0); // angularity (girth)
   fastjet_shaoes::GeneralisedAngularity(1.0, 0.5); // angularity (smaller supposedly more efficient)
   fastjet_shaoes::GeneralisedAngularity(0.0, 0.0); // multiplicity
   fastjet_shaoes::GeneralisedAngularity(2.0, 0.0); // pTD^2

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

File contents
=============

- Shapes.{hh,cc}: contains (FastJet-style) implementation of useful
  jet shapes (only GeneralisedAngularity so far)

Contributors
============

Gregory Soyez
Jesse Thaler

