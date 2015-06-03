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


  /// Standard jet radius used in this analysis (for both kT and anti-kT)
  const double JET_RADIUS = 0.6;

  class MC_LHQG : public Analysis {
  public:

    /// Constructor
    MC_LHQG()
      : Analysis("MC_LHQG")
    {    }


    /// Book histograms and initialise projections before the run
    void init() {

      FinalState fs(-2.5, 2.5, 0.0*GeV);
      VetoedFinalState jet_input(fs);
      jet_input.vetoNeutrinos();
      jet_input.addVetoPairId(PID::MUON);
      addProjection(jet_input, "JET_INPUT");
      addProjection(FastJets(jet_input, FastJets::ANTIKT, JET_RADIUS), "Jets");


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
       double scalar_pt = 0;
     
      const FastJets& fastjets = applyProjection<FastJets>(e, "Jets");
      const Jets jets = fastjets.jetsByPt(400.*GeV);

      if(jets.size() < 1) vetoEvent;

       // Angularities
        
          foreach (const Particle& p, jets[0].particles()){          
          scalar_pt += p.pT();
          sum1020 += pow(p.pT(), 2.0) * pow(deltaR(p, jets[0]), 1.0);
          sum1010 += pow(p.pT(), 1.0) * pow(deltaR(p, jets[0]), 1.0);
          sum1005 += pow(p.pT(), 0.5) * pow(deltaR(p, jets[0]), 1.0);
          sum0000 += pow(p.pT(), 0.0) * pow(deltaR(p, jets[0]), 0.0);
          sum2000 += pow(p.pT(), 0.0) * pow(deltaR(p, jets[0]), 2.0);
          }
        
          ga1020 = sum1020/ pow(scalar_pt, 2.0) * pow(JET_RADIUS, 1.0);
          ga1010 = sum1010/ pow(scalar_pt, 1.0) * pow(JET_RADIUS, 1.0);
          ga1005 = sum1005/ pow(scalar_pt, 0.5) * pow(JET_RADIUS, 1.0);
          ga0000 = sum0000/ pow(scalar_pt, 0.0) * pow(JET_RADIUS, 1.0);
          ga2000 = sum2000/ pow(scalar_pt, 0.0) * pow(JET_RADIUS, 2.0); 
          
          _h_ga1020 -> fill(ga1020, weight);
          _h_ga1010 -> fill(ga1010, weight);
          _h_ga1005 -> fill(ga1005, weight);
          _h_ga0000 -> fill(ga0000, weight);
          _h_ga2000 -> fill(ga2000, weight);
             
     
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

  };



  // Hook for the plugin system
  DECLARE_RIVET_PLUGIN(MC_LHQG);

}
