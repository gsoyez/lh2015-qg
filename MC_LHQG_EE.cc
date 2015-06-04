//Based on Andy Buckley's Boost 2014 Analysis

// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/FastJets.hh"
#include "Rivet/Projections/FinalState.hh"
#include "Rivet/Projections/IdentifiedFinalState.hh"
#include "Rivet/Projections/VetoedFinalState.hh"


#include "fastjet/JetDefinition.hh"
#include "fastjet/ClusterSequence.hh"

using namespace fastjet;


namespace Rivet {

  
  class MC_LHQG_EE : public Analysis {
  public:

    /// Parameters
    const double JET_RADIUS;          ///< jet radius
    const double JET_EMIN_OVER_SQRTS; ///< jet energy cut as a fraction of the total energy 

    /// Constructor
    MC_LHQG_EE()
      : Analysis("MC_LHQG_EE"),
        JET_RADIUS(0.6),
        JET_EMIN_OVER_SQRTS(0.4){}

    /// Book histograms and initialise projections before the run
    void init() {

      FinalState fs;
      VetoedFinalState jet_input(fs);
      jet_input.vetoNeutrinos();
      jet_input.addVetoPairId(PID::MUON);
      addProjection(jet_input, "JET_INPUT");

      _jet_def = JetDefinition(ee_genkt_algorithm, JET_RADIUS, -1.0, WTA_modp_scheme);

      _h_ga1020 =  bookHisto1D("GA_10_20",1000,0,1);
      _h_ga1010 =  bookHisto1D("GA_10_10",1000,0,1);
      _h_ga1005 =  bookHisto1D("GA_10_05",1000,0,1);
      _h_ga0000 =  bookHisto1D("GA_00_00",301,-0.5,300.5);
      _h_ga2000 =  bookHisto1D("GA_20_00",1000,0,1);
    }


    /// Perform the per-event analysis
    void analyze(const Event& e) {
      const double weight = e.weight();
     
      double sum1020 (0), sum1010 (0), sum1005 (0), sum0000 (0), sum2000 (0);
      double ga1020, ga1010, ga1005, ga0000, ga2000;

      // do the clustering
      //
      // we'll keep jets above a certain fraction of the total energy 
      const VetoedFinalState &fs = applyProjection<VetoedFinalState>(e, "JET_INPUT");
      vector<PseudoJet> particles;
      double Q = 0.0;
      particles.reserve(fs.particles().size());
      foreach (const Particle &p, fs.particles()){
        particles.push_back(p.pseudojet());
        Q += p.E();
      }
      vector<PseudoJet> jets = SelectorEMin(JET_EMIN_OVER_SQRTS*Q)(_jet_def(particles));
      
      if(!jets.size()) vetoEvent;

      foreach (const PseudoJet &jet, jets){
        // Angularities        
        foreach (const PseudoJet& p, jet.constituents()){
          double E = p.E();
          double theta = _angle(p, jet);
          sum1020 += pow(E, 1.0) * pow(theta, 2.0);
          sum1010 += pow(E, 1.0) * pow(theta, 1.0);
          sum1005 += pow(E, 1.0) * pow(theta, 0.5);
          sum0000 += pow(E, 0.0) * pow(theta, 0.0);
          sum2000 += pow(E, 2.0) * pow(theta, 0.0);
        }
        
        ga1020 = sum1020/ pow(jet.E(), 1.0) * pow(JET_RADIUS, 2.0);
        ga1010 = sum1010/ pow(jet.E(), 1.0) * pow(JET_RADIUS, 1.0);
        ga1005 = sum1005/ pow(jet.E(), 1.0) * pow(JET_RADIUS, 0.5);
        ga0000 = sum0000/ pow(jet.E(), 0.0) * pow(JET_RADIUS, 0.0);
        ga2000 = sum2000/ pow(jet.E(), 2.0) * pow(JET_RADIUS, 0.0); 
          
        _h_ga1020 -> fill(ga1020, weight);
        _h_ga1010 -> fill(ga1010, weight);
        _h_ga1005 -> fill(ga1005, weight);
        _h_ga0000 -> fill(ga0000, weight);
        _h_ga2000 -> fill(ga2000, weight);
      }             
     
    }
     
    /// Normalise histograms etc., after the run
    void finalize() {
     
      normalize(_h_ga1020);
      normalize(_h_ga1010);
      normalize(_h_ga1005);
      normalize(_h_ga0000);
      normalize(_h_ga2000);
    }


  private:

    Histo1DPtr _h_ga1020, _h_ga1010, _h_ga1005, _h_ga0000, _h_ga2000;
    JetDefinition _jet_def;

    double _angle(const PseudoJet& jet1, const PseudoJet& jet2) const {
      // doesn't seem to be a fastjet built in for this
      double dot = jet1.px()*jet2.px() + jet1.py()*jet2.py() + jet1.pz()*jet2.pz();
      double norm1 = sqrt(jet1.px()*jet1.px() + jet1.py()*jet1.py() + jet1.pz()*jet1.pz());
      double norm2 = sqrt(jet2.px()*jet2.px() + jet2.py()*jet2.py() + jet2.pz()*jet2.pz());
      
      double costheta = dot/(norm1 * norm2);
      if (costheta > 1.0) costheta = 1.0; // Need to handle case of numerical overflow
      return acos(costheta);
    }

  };



  // Hook for the plugin system
  DECLARE_RIVET_PLUGIN(MC_LHQG_EE);

}
