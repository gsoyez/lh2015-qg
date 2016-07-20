//Based on Andy Buckley's Boost 2014 Analysis

// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/FastJets.hh"
#include "Rivet/Projections/FinalState.hh"
#include "Rivet/Projections/IdentifiedFinalState.hh"
#include "Rivet/Projections/VetoedFinalState.hh"

#include "fastjet/JetDefinition.hh"
#include "fastjet/ClusterSequence.hh"
#include "fastjet/tools/Recluster.hh"
#include "fastjet/contrib/ModifiedMassDropTagger.hh"
using namespace fastjet;



namespace Rivet {

  using namespace Cuts;

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


  /// Standard jet radius used in this analysis (for both kT and anti-kT)

  class MC_LHQG_dijet : public Analysis {
  public:

    /// parameters
    const double JET_AVG_PTMIN;       ///< minimal pt for the avg of the 2 hardest jets pt
    const double JET_MIN_PT_FRACTION; ///< 2nd hardest needs to e at least that fraction of hardest
    const double DELTA_RAP_MAX_DIJET; ///< max rapidity difference between the two jets
    const double LOG_SCALE_MAX;       ///< max value of for the log binning (abs)
    const unsigned int nRADII;        ///< number of radii under consideration
    const double DELTA_RADII;         ///< radius step size
    const double PARTICLE_RAPMAX;    ///< maximal rapidity allowed for particles
    const double JET_RAPMAX;         ///< maximal rapidity allowed for jets
    
    /// Constructor
    MC_LHQG_dijet()
      : Analysis("MC_LHQG_dijet"),
        JET_AVG_PTMIN(100.0),      // avg of the two hardest has that minimum
        JET_MIN_PT_FRACTION(0.8),  // 2nd hardest is at least 0.8 * hardest
        DELTA_RAP_MAX_DIJET(1.0),
        LOG_SCALE_MAX(15.0),
        nRADII(5),
        DELTA_RADII(0.2),
        PARTICLE_RAPMAX(2.5),
        JET_RAPMAX(1.5)
    {}
    
    /// Book histograms and initialise projections before the run
    void init() {
      
      FinalState fs(-PARTICLE_RAPMAX, PARTICLE_RAPMAX, 0.0*GeV);
      
      // for the jets
      VetoedFinalState jet_input(fs);
      jet_input.vetoNeutrinos();
      jet_input.addVetoPairId(PID::MUON);
      addProjection(jet_input, "JET_INPUT");

      // mMDT
      ca_wta_recluster = Recluster(JetDefinition(cambridge_algorithm, JetDefinition::max_allowable_R, WTA_pt_scheme),
                                   false, Recluster::keep_only_hardest);
      mmdt.reset(new contrib::ModifiedMassDropTagger(0.1));
      mmdt->set_grooming_mode();
      mmdt->set_reclustering(false);

      // shape parameter definitions
      _kappa_betas.push_back(pair_double(0.0, 0.0));
      _kappa_betas.push_back(pair_double(1.0, 0.5));
      _kappa_betas.push_back(pair_double(1.0, 1.0));
      _kappa_betas.push_back(pair_double(1.0, 2.0));
      _kappa_betas.push_back(pair_double(2.0, 0.0));

      // histogram bbookings
      for (unsigned int iR=1;iR<nRADII+1; iR++){
        double R=DELTA_RADII*iR;
        ostringstream Rlabel;
        Rlabel << "_R" << (int)(10*R);
        string Rlab = Rlabel.str();

        // plain jet quantities
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

        // mMDT quantities
        _gas.push_back(HistogramHolder(bookHisto1D("mMDT_GA_00_00"+Rlab,151,-0.5,150.5),
                                       bookHisto1D("log_mMDT_GA_00_00"+Rlab,300,0,6)));
        _gas.push_back(HistogramHolder(bookHisto1D("mMDT_GA_10_05"+Rlab, 500, 0.0, 1.0),
                                       bookHisto1D("log_mMDT_GA_10_05"+Rlab, 500, -LOG_SCALE_MAX, 0.0)));
        _gas.push_back(HistogramHolder(bookHisto1D("mMDT_GA_10_10"+Rlab, 500, 0.0, 1.0),
                                       bookHisto1D("log_mMDT_GA_10_10"+Rlab, 500, -LOG_SCALE_MAX, 0.0)));
        _gas.push_back(HistogramHolder(bookHisto1D("mMDT_GA_10_20"+Rlab, 500, 0.0, 1.0),
                                       bookHisto1D("log_mMDT_GA_10_20"+Rlab, 500, -LOG_SCALE_MAX, 0.0)));
        _gas.push_back(HistogramHolder(bookHisto1D("mMDT_GA_20_00"+Rlab, 500, 0.0, 1.0),
                                       bookHisto1D("log_mMDT_GA_20_00"+Rlab, 500, -LOG_SCALE_MAX, 0.0)));

        // control plots
        h_delta_phi_dijet.push_back(bookHisto1D("deltaphi_dijet"+Rlab, 100, 0.0, pi));
      }
    }


    /// Perform the per-event analysis
    void analyze(const Event& e) {
      // a few shortcuts
      const double weight = e.weight();

      // get the jet inputs
      const VetoedFinalState &fs = applyProjection<VetoedFinalState>(e, "JET_INPUT");
      vector<PseudoJet> particles;
      particles.reserve(fs.particles().size());
      foreach (const Particle &p, fs.particles()){
        particles.push_back(p.pseudojet());
      }

      unsigned int ngas = _kappa_betas.size();

      // min jet pt: pt1+pt2=2*avg and pt2=frac*pt1
      //             => (1+1/frac) pt2 = 2 avg
      //             => pt2 = 2frac/(1+frac) avg
      double ptmin_jet = 2*JET_MIN_PT_FRACTION/(1+JET_MIN_PT_FRACTION)*JET_AVG_PTMIN;       
      
      // loop over jet radii
      for (unsigned int iR=0;iR<nRADII; iR++){
        // do the clustering
        //
        // we'll keep jets above a certain fraction of the total energy 
        double R=DELTA_RADII*(iR+1);
        //JetDefinition jet_def(antikt_algorithm, R, WTA_pt_scheme);
        JetDefinition jet_def(antikt_algorithm, R);
        vector<PseudoJet> jets = (SelectorNHardest(2) * SelectorAbsRapMax(JET_RAPMAX) * SelectorPtMin(ptmin_jet))(jet_def(particles));
      
        if(jets.size()<2) continue;

        // impose the cuts
        PseudoJet orig_jet1 = jets[0];
        PseudoJet orig_jet2 = jets[1];

        if (orig_jet1.pt() + orig_jet2.pt() < 2*JET_AVG_PTMIN) continue;
        if (orig_jet2.pt() / orig_jet1.pt() < JET_MIN_PT_FRACTION) continue;

        // require that the jets are within 1 unit in rapidity of each other
        if (std::abs(orig_jet1.rap()-orig_jet2.rap())<DELTA_RAP_MAX_DIJET) continue;

        // control plot: deltaphi with the Z boson
        double dphi = std::abs(orig_jet2.delta_phi_to(orig_jet1));
        h_delta_phi_dijet[iR]->fill(dphi, weight);
        
        // grooming
        PseudoJet jet1 = ca_wta_recluster(orig_jet1);
        PseudoJet jet2 = ca_wta_recluster(orig_jet2);

        PseudoJet mmdt_jet1 = (*mmdt)(jet1);
        PseudoJet mmdt_jet2 = (*mmdt)(jet2);

        // calculate shapes
        compute_and_record(jet1,      R, ngas*(2*iR),   weight);
        compute_and_record(mmdt_jet1, R, ngas*(2*iR+1), weight);
        
        compute_and_record(jet2,      R, ngas*(2*iR),   weight);
        compute_and_record(mmdt_jet2, R, ngas*(2*iR+1), weight);
        
      } // loop over radii
      
    }
     
    /// Normalise histograms etc., after the run
    void finalize() {
      foreach (const HistogramHolder &ho, _gas){
        normalize(ho.h);
        normalize(ho.h_log);
      }
    }


  private:
    vector<pair_double> _kappa_betas;
    vector<HistogramHolder> _gas;
    vector<Histo1DPtr> h_delta_phi_dijet;
    
    Recluster ca_wta_recluster;
    SharedPtr<contrib::ModifiedMassDropTagger> mmdt;

    void compute_and_record(const PseudoJet &jet, double R, unsigned int offset, double weight){
      unsigned int ngas = _kappa_betas.size();
      vector<double> gas(ngas);

      // init angularity sums to 0
      for(unsigned int i=0; i<ngas;i++) gas[i]=0.0;

      // sum over the constituents
      foreach (const PseudoJet& p, jet.constituents()){
        double pt = p.pt();
        double theta = p.squared_distance(jet);
        for(unsigned int i=0; i<ngas;i++)
          gas[i]+=pow(pt, _kappa_betas[i].first) * pow(theta, 0.5*_kappa_betas[i].second);
      }
      
      // normalise and fill histograms
      for(unsigned int i=0; i<ngas;i++){ 
        gas[i]/=(pow(jet.pt(), _kappa_betas[i].first) * pow(R, _kappa_betas[i].second));

        //assert(ngas*iR+i < _gas.size());
        _gas[offset+i].h->fill(gas[i], weight);
        // for the log binning make sure we avoid taking log(0) and put
        // that in the most -ve bin.
        _gas[offset+i].h_log->fill(gas[i]>0 ? log(gas[i]) : 1e-5-LOG_SCALE_MAX, weight);
      }
    }
  };
  


  // Hook for the plugin system
  DECLARE_RIVET_PLUGIN(MC_LHQG_dijet);

}
