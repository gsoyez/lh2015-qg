//Based on Andy Buckley's Boost 2014 Analysis

// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/FastJets.hh"
#include "Rivet/Projections/FinalState.hh"
#include "Rivet/Projections/IdentifiedFinalState.hh"
#include "Rivet/Projections/VetoedFinalState.hh"
#include "Rivet/Projections/ZFinder.hh"

#include "fastjet/JetDefinition.hh"
#include "fastjet/ClusterSequence.hh"
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

  class MC_LHQG_Zjet : public Analysis {
  public:

    /// parameters
    const double BOSON_PTMIN;        ///< minimal boson pt
    const double JET_PTMIN_FRACTION; ///< min value of jet_pt/boson_pt
    const double LOG_SCALE_MAX;      ///< max value of for the log binning (abs)
    const unsigned int nRADII;       ///< number of radii under consideration
    const double DELTA_RADII;        ///< radius step size

    
    /// Constructor
    MC_LHQG_Zjet()
      : Analysis("MC_LHQG_Zjet"),
        BOSON_PTMIN(100.0),
        JET_PTMIN_FRACTION(0.6),
        LOG_SCALE_MAX(15.0),
        nRADII(5),
        DELTA_RADII(0.2)
    {}
    
    /// Book histograms and initialise projections before the run
    void init() {
      
      FinalState fs(-4, 4, 0.0*GeV);
      
      // for the Z boson (-> mumu)
      Cut cut =  pT >= JET_PTMIN_FRACTION*GeV;
      ZFinder zfinder_mm_bare(fs, cut, PID::MUON, 66.0*GeV, 116.0*GeV, 0.0, ZFinder::CLUSTERNODECAY, ZFinder::NOTRACK);
      addProjection(zfinder_mm_bare, "ZFinder_mm_bare");
      
      // for the jets
      VetoedFinalState jet_input(fs);
      jet_input.vetoNeutrinos();
      jet_input.addVetoPairId(PID::MUON);
      addProjection(jet_input, "JET_INPUT");

      // mMDT
      mmdt.reset(new contrib::ModifiedMassDropTagger(0.1));
      mmdt->set_grooming_mode();
      mmdt->set_reclustering(true);

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
      }
    }


    /// Perform the per-event analysis
    void analyze(const Event& e) {
      // see if we find a Z boson
      const ZFinder& zfinder  = applyProjection<ZFinder>(e, "ZFinder_mm_bare"   );
      if (zfinder.bosons().size() != 1) return;

      // deduce the cut to apply on jets
      const FourMomentum zmom = zfinder.bosons()[0].momentum();
      double ptmin_jet = JET_PTMIN_FRACTION*zmom.pT();

      // a few shortcuts
      const double weight = e.weight();

      const VetoedFinalState &fs = applyProjection<VetoedFinalState>(e, "JET_INPUT");
      vector<PseudoJet> particles;
      particles.reserve(fs.particles().size());
      foreach (const Particle &p, fs.particles()){
        particles.push_back(p.pseudojet());
      }

      unsigned int ngas = _kappa_betas.size();

      // loop over jet radii
      for (unsigned int iR=0;iR<nRADII; iR++){
        // do the clustering
        //
        // we'll keep jets above a certain fraction of the total energy 
        double R=DELTA_RADII*(iR+1);
        JetDefinition jet_def(antikt_algorithm, R, WTA_pt_scheme);
        vector<PseudoJet> jets = SelectorPtMin(ptmin_jet)(jet_def(particles));
      
        if(!jets.size()) continue;

        // select only the hardest jet
        PseudoJet jet = (SelectorNHardest(1)(jets))[0];
        PseudoJet mmdt_jet = (*mmdt)(jet);

        compute_and_record(jet,      R, ngas*(2*iR),   weight);
        compute_and_record(mmdt_jet, R, ngas*(2*iR+1), weight);
        
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
  DECLARE_RIVET_PLUGIN(MC_LHQG_Zjet);

}
