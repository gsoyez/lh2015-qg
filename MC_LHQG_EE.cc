//Based on Andy Buckley's Boost 2014 Analysis

// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/Thrust.hh"
#include "Rivet/Projections/FastJets.hh"
#include "Rivet/Projections/FinalState.hh"
#include "Rivet/Projections/IdentifiedFinalState.hh"
#include "Rivet/Projections/VetoedFinalState.hh"
#include <sstream>


#include "fastjet/JetDefinition.hh"
#include "fastjet/ClusterSequence.hh"

using namespace fastjet;


namespace Rivet {

  // a helper that holds
  //  - a jet radius
  //  - a kappa value
  //  - a beta value
  //  - an associated histogram with lin binning
  //  - an associated histogram with log binning
  class HistogramHolder{
  public:
    HistogramHolder(Histo1DPtr h_in, Histo1DPtr h_log_in)
      : h(h_in), h_log(h_log_in){}
    Histo1DPtr h, h_log;
  };

  typedef pair<double, double> pair_double; // will hold a (kappa,beta) pair

  // the analysis itself
  class MC_LHQG_EE : public Analysis {
  public:

    /// Parameters
    const double JET_EMIN_OVER_SQRTS; ///< jet energy cut as a fraction of the total energy 
    const double LOG_SCALE_MAX;       ///< max value of for the log binning (abs)
    const unsigned int nRADII;        ///< number of radii under consideration
    const double DELTA_RADII;         ///< radius step size
    const double LAMBDA;              ///< non-perturbative cut for the "hadronic thrust" region [GeV]
    
    /// Constructor
    MC_LHQG_EE()
      : Analysis("MC_LHQG_EE"),
        JET_EMIN_OVER_SQRTS(0.4),
        LOG_SCALE_MAX(15.0),
        nRADII(3),
        DELTA_RADII(0.3),
        LAMBDA(5.0){}

    /// Book histograms and initialise projections before the run
    void init() {
      FinalState fs;
      VetoedFinalState jet_input(fs);
      jet_input.vetoNeutrinos();
      addProjection(jet_input, "JET_INPUT");

      Thrust thrust(jet_input);
      addProjection(thrust, "THRUST");

      _kappa_betas.push_back(pair_double(0.0, 0.0));
      _kappa_betas.push_back(pair_double(1.0, 0.5));
      _kappa_betas.push_back(pair_double(1.0, 1.0));
      _kappa_betas.push_back(pair_double(1.0, 2.0));
      _kappa_betas.push_back(pair_double(2.0, 0.0));
      
      for (unsigned int iR=1;iR<nRADII+1; iR++){
        double R=DELTA_RADII*iR;
        ostringstream Rlabel;
        Rlabel << "_R" << (int)(10*R);
        string Rlab = Rlabel.str();

        _gas.push_back(HistogramHolder(bookHisto1D("GA_00_00"+Rlab,151,-0.5,150.5),
                                       bookHisto1D("log_GA_00_00"+Rlab,300,0,6)));
        _gas.push_back(HistogramHolder(bookHisto1D("GA_10_05"+Rlab, 500, 0.0, 1.0),
                                       bookHisto1D("log_GA_10_05"+Rlab, 500, -LOG_SCALE_MAX, 0.0)));
        _gas.push_back(HistogramHolder(bookHisto1D("GA_10_10"+Rlab, 500, 0.0, 1.0),
                                       bookHisto1D("log_GA_10_10"+Rlab, 500, -LOG_SCALE_MAX, 0.0)));
        _gas.push_back(HistogramHolder(bookHisto1D("GA_10_20"+Rlab, 500, 0.0, 1.0),
                                       bookHisto1D("log_GA_10_20"+Rlab, 500, -LOG_SCALE_MAX, 0.0)));
        _gas.push_back(HistogramHolder(bookHisto1D("GA_20_00"+Rlab, 500, 0.0, 1.0),
                                       bookHisto1D("log_GA_20_00"+Rlab, 500, -LOG_SCALE_MAX, 0.0)));
      }

      // declare the other measures: thrust and multiplicity for various thrust bins
      _h_thrust = bookHisto1D("Thrust", 500, 0.5, 1.0);
      _h_log_thrust = bookHisto1D("Thrust_log", 500, -LOG_SCALE_MAX, 0.0);
      _h_multiplicity_for_hadron_thrust       = bookHisto1D("MultHadronThrust",      301, -0.5, 300.5);
      _h_multiplicity_for_intermediate_thrust = bookHisto1D("MultIntermediasThrust", 301, -0.5, 300.5);
      _h_multiplicity_for_shower_thrust       = bookHisto1D("MultShowerThrust",      301, -0.5, 300.5);
      _h_multiplicity_for_hard_thrust         = bookHisto1D("MultHardThrust",        301, -0.5, 300.5);

    }


    /// Perform the per-event analysis
    void analyze(const Event& e) {
      const double weight = e.weight();
      
      // get the event and its total energy
      const VetoedFinalState &fs = applyProjection<VetoedFinalState>(e, "JET_INPUT");
      vector<PseudoJet> particles;
      double Q = 0.0;
      particles.reserve(fs.particles().size());
      foreach (const Particle &p, fs.particles()){
        particles.push_back(p.pseudojet());
        Q += p.E();
      }

      unsigned int ngas = _kappa_betas.size();
      vector<double> gas(ngas);

      // loop over jet radii
      for (unsigned int iR=0;iR<nRADII; iR++){
        // do the clustering
        //
        // we'll keep jets above a certain fraction of the total energy 
        double R=DELTA_RADII*(iR+1);
        JetDefinition jet_def(ee_genkt_algorithm, R, -1.0, WTA_modp_scheme);
        vector<PseudoJet> jets = SelectorEMin(JET_EMIN_OVER_SQRTS*Q)(jet_def(particles));
      
        if(!jets.size()) continue;

        // loop over the jets
        foreach (const PseudoJet &jet, jets){
          // init angularity sums to 0
          for(unsigned int i=0; i<ngas;i++) gas[i]=0.0;

          // sum over the constituents
          foreach (const PseudoJet& p, jet.constituents()){
            double E = p.E();
            double theta = _angle(p, jet);
            for(unsigned int i=0; i<ngas;i++)
              gas[i]+=pow(E, _kappa_betas[i].first) * pow(theta, _kappa_betas[i].second);
          }

          // normalise and fill histograms
          for(unsigned int i=0; i<ngas;i++){ 
            gas[i]/=(pow(jet.E(), _kappa_betas[i].first) * pow(R, _kappa_betas[i].second));
            assert(ngas*iR+i < _gas.size());
            _gas[ngas*iR+i].h->fill(gas[i], weight);
            // for the log binning make sure we avoid taking log(0) and put
            // that in the most -ve bin.
            _gas[ngas*iR+i].h_log->fill(gas[i]>0 ? log(gas[i]) : 1e-5-LOG_SCALE_MAX, weight);
          }
        } // loop over jets
      } // loop over radii

      // get thrust
      const Thrust &thrust_proj = applyProjection<Thrust>(e, "THRUST");
      double thrust = thrust_proj.thrust();

      _h_thrust->fill(thrust, weight);
      _h_log_thrust->fill(thrust<1 ? log(1-thrust) : 1e-5-LOG_SCALE_MAX, weight);

      if (1-thrust<LAMBDA/Q){
        _h_multiplicity_for_hadron_thrust->fill(particles.size(), weight);
      } else if (1-thrust<0.1){
        _h_multiplicity_for_intermediate_thrust->fill(particles.size(), weight);
      } else if (1-thrust<0.2){
        _h_multiplicity_for_shower_thrust->fill(particles.size(), weight);
      } else{
        _h_multiplicity_for_hard_thrust->fill(particles.size(), weight);
      }
    }
     
    /// Normalise histograms etc., after the run
    void finalize() {
      foreach (const HistogramHolder &ho, _gas){
        normalize(ho.h);
        normalize(ho.h_log);
      }

      normalize(_h_thrust);
      normalize(_h_log_thrust);

      normalize(_h_multiplicity_for_hadron_thrust);
      normalize(_h_multiplicity_for_intermediate_thrust);
      normalize(_h_multiplicity_for_shower_thrust);
      normalize(_h_multiplicity_for_hard_thrust);
    }


  private:
    vector<pair_double> _kappa_betas;
    
    vector<HistogramHolder> _gas;
    Histo1DPtr _h_thrust;
    Histo1DPtr _h_log_thrust;
    Histo1DPtr _h_multiplicity_for_hadron_thrust;
    Histo1DPtr _h_multiplicity_for_intermediate_thrust;
    Histo1DPtr _h_multiplicity_for_shower_thrust;
    Histo1DPtr _h_multiplicity_for_hard_thrust;
    
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
