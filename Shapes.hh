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

#ifndef __FASTJET_SHAPES_HH__
#define __FASTJET_SHAPES_HH__

#include <fastjet/PseudoJet.hh>
#include <fastjet/FunctionOfPseudoJet.hh>
#include <fastjet/tools/Recluster.hh>

/// put everything in a specific namespace to avoid potential conflict
namespace fastjet_shapes{

  /// define a generic shortcut for shapes
  typedef fastjet::FunctionOfPseudoJet<double> Shape;

  //------------------------------------------------------------------------
  /// \class GeneralisedAngularity
  /// generalised angularities as defined in arXiv:1408.3122
  ///
  /// generalised angularities depend on two parameters \kappa and \beta and are defined as
  ///
  /// \f[
  ///   \lambda_\beta^\kappa
  ///      = \tilde p_{t,\rm jet}^{-\kappa} R^{-\beta} \sum_{i \in \rm jet} p_{t,i}^\kappa \theta_i^\beta
  /// \f]
  ///
  /// where R is the jet radius, \theta the distance between particle
  /// i and the jet axis, the sum runs over the constituents of the
  /// jet, and the normalisation uses the scalar pt of the jet (scalar
  /// sum of the pt of its constituents)
  ///
  /// For generic usage, we also introduced a version working with
  /// energies and "opening angles" for use in e+e- collisions.  This
  /// is controlled by the "Measure" which can be either pt_R (the
  /// default) or E_theta.
  ///
  /// Optionally, the constructor takes a REcluster object that is
  /// used to recluster the jet to "re-calculate" the jet axis to
  /// use. That re-calculated jet will just be used for the distance
  /// calculation.
  class GeneralisedAngularity : public Shape{
  public:
    enum Measure {
      pt_R,    ///< use transverse momenta and boost-invariant angles, 
               ///< eg \f$\mathrm{ECF}(2,\beta) = \sum_{i<j} p_{ti} p_{tj} \Delta R_{ij}^{\beta} \f$
      E_theta  ///  use energies and angles, 
               ///  eg \f$\mathrm{ECF}(2,\beta) = \sum_{i<j} E_{i} E_{j}   \theta_{ij}^{\beta} \f$
    };
    
    /// default ctor
    /// \param kappa     the exponent of the jet transverse momentum fraction
    /// \param beta      the exponent of the distance to the jet axis
    /// \param R         the jet radius
    /// \param measure   pt_R (pp collisions -- the default) or E_theta (ee collisions)
    /// \param recluster an optional reclusterer to recalculate the axis reference
    GeneralisedAngularity(double kappa_in, double beta_in, double R_in,
                          Measure measure_in = pt_R,
                          const fastjet::Recluster *recluster_in=0)
      : _kappa(kappa_in), _beta(beta_in), _R(R_in),
        _half_beta(0.5*beta_in),
        _measure(measure_in), _recluster(recluster_in){}

    /// default dtor
    virtual ~GeneralisedAngularity(){}
    
    /// description of the shape
    virtual std::string description() const;

    /// retreive basic info
    double kappa() const{ return _kappa;} 
    double beta()  const{ return _beta;}
    double R()     const{ return _R;}
    Measure measure() const { return _measure; }
    const fastjet::Recluster* recluster() const { return _recluster;}
    
    /// the computation of the shape itself
    double result(const fastjet::PseudoJet &jet) const;

  protected:
    double _kappa, _beta, _R;
    double _half_beta;
    Measure _measure;
    const fastjet::Recluster *_recluster;

    /// compute the geometric (3D) angle between 2 4-vectors
    double _angle(const fastjet::PseudoJet& jet1,
                  const fastjet::PseudoJet& jet2) const;

  };

} // nanespace fastjet_shapes

#endif //  __FASTJET_SHAPES_HH__
