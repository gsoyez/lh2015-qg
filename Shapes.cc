// $Id$
//
// Copyright (c) 2015-, Gregory Soyez
//
//----------------------------------------------------------------------
// This file is originally part of the work done in the context of
// quark-gluon tagging for the Les Houches workshop in June 2015
//
// This is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Note that code for some of the tools implemented here had already
// be made available previously.
// ----------------------------------------------------------------------

#include "Shapes.hh"
#include <sstream>
#include <cmath>

using namespace std;
using namespace fastjet;

/// put everything in a specific namespace to avoid potential conflict
namespace fastjet_shapes{

  //------------------------------------------------------------------------
  // GeneralisedAngularity implementation
  //------------------------------------------------------------------------
  
  // description of the shape
  std::string GeneralisedAngularity::description() const{
    ostringstream oss;
    oss << "(Generalised) angularity with kappa=" << _kappa
        << ", beta=" << _beta
        << ", R=" << _R;
    if (_recluster) oss << ", "; else oss << " and ";
    if (_measure == pt_R)
      oss << "pt_R measure";
    else
      oss << "E_theta measure";
    if (_recluster)
      oss << " and reclustering using ("
          << _recluster->description() << ")";
    return oss.str();
  }
      
    
  // the computation of the shape itself
  double GeneralisedAngularity::result(const PseudoJet &jet) const{
    const vector<PseudoJet> &constits = jet.constituents();
    unsigned int n = constits.size();

    /// return 0 if the jet is empty (convention)
    if (n==0){ return 0.0;}

    // recalculate the jet axis if needed
    PseudoJet axis = (_recluster)
      ? (*_recluster)(jet)
      : jet;

    // compute the shape looping over the constituents
    double sum = 0.0;
    if (_measure == pt_R){
      // first handle the pt_R case (pp collisions)
      double scalar_pt = 0.0;
      for(unsigned int i=0; i<n; i++){
        const PseudoJet &p = constits[i];
        double pt = p.pt();
        scalar_pt += pt;
        sum += pow(pt, _kappa) * pow(axis.squared_distance(p), _half_beta);
      }
      sum /= pow(sclar_pt, _kappa) * pow(_R,_beta);
    } else {
      // then handle the E_theta case (ee collisions)
      for(unsigned int i=0; i<n; i++){
        const PseudoJet &p = constits[i];
        sum += pow(p.E(), _kappa) * pow(_angle(axis,p), _beta);
      }
      sum /= pow(axis.E(), _kappa) * pow(_R,_beta);
    }
    return sum;
  }

  // mostly taken from EnergyCorrelationFunction
  double GeneralisedAngularity::_angle(const PseudoJet& jet1, const PseudoJet& jet2) const {
    // doesn't seem to be a fastjet built in for this
    double dot = jet1.px()*jet2.px() + jet1.py()*jet2.py() + jet1.pz()*jet2.pz();
    double norm1 = sqrt(jet1.px()*jet1.px() + jet1.py()*jet1.py() + jet1.pz()*jet1.pz());
    double norm2 = sqrt(jet2.px()*jet2.px() + jet2.py()*jet2.py() + jet2.pz()*jet2.pz());
    
    double costheta = dot/(norm1 * norm2);
    if (costheta > 1.0) costheta = 1.0; // Need to handle case of numerical overflow
    return acos(costheta);
  }
 
}
