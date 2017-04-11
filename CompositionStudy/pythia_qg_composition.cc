#include "Pythia8/Pythia.h"
#include <cassert>

using namespace Pythia8;

Pythia pythias[5][13];
double quark_count[5][13];
double gluon_count[5][13];

int main(int argc, char *argv[]) {
   
   assert(argc == 2);
   
   // Number of events to generate
   string NEVstring = string(argv[1]);
   int NEV = atoi(argv[1]);
   
   

   vector<string> process_files;
   process_files.push_back("process1_dijet");
   process_files.push_back("process2_Wjet");
   process_files.push_back("process3_Zjet");
   process_files.push_back("process4_Hjet");
   process_files.push_back("process5_gammajet");
   int num_process_files = 5;
   assert(num_process_files == process_files.size());
   
   vector<double> pt_cuts;
   pt_cuts.push_back(25.0/sqrt(2.0));
   pt_cuts.push_back(25.0);
   pt_cuts.push_back(25.0*sqrt(2.0));
   pt_cuts.push_back(50.0);
   pt_cuts.push_back(50.0*sqrt(2.0));
   pt_cuts.push_back(100.0);
   pt_cuts.push_back(100.0*sqrt(2.0));
   pt_cuts.push_back(200.0);
   pt_cuts.push_back(200.0*sqrt(2.0));
   pt_cuts.push_back(400.0);
   pt_cuts.push_back(400.0*sqrt(2.0));
   pt_cuts.push_back(800.0);
   pt_cuts.push_back(800.0*sqrt(2.0));
   int num_pt_cuts = 13;
   assert(num_pt_cuts == pt_cuts.size());
   
//   Pythia pythias[num_process_files][num_pt_cuts];
//   double quark_count[num_process_files][num_pt_cuts];
//   double gluon_count[num_process_files][num_pt_cuts];
   
   for (int j = 0; j < num_process_files; j++) {
      for (int k = 0; k < num_pt_cuts; k++) {

         Pythia& this_pythia = pythias[j][k];
         quark_count[j][k] = 0;
         gluon_count[j][k] = 0;
         
         this_pythia.readFile(process_files.at(j) + ".in");
         this_pythia.settings.parm("PhaseSpace:pTHatMin",pt_cuts.at(k));

         this_pythia.settings.parm("Beams:eCM",13000.0);
         this_pythia.settings.readString("ProcessLevel:resonanceDecays = off");
         this_pythia.settings.readString("PartonLevel:all = off");
         this_pythia.settings.readString("HadronLevel:all = off");
         
         
         this_pythia.init();
         
      }
   }
   
   // Begin event loop. Generate event. Skip if error. List first few.
   for (int iEvent = 0; iEvent<NEV; ++iEvent) {
  
      for (int j = 0; j < num_process_files; j++) {
         for (int k = 0; k < num_pt_cuts; k++) {

            Pythia& this_pythia = pythias[j][k];
            double& this_quark_count = quark_count[j][k];
            double& this_gluon_count = gluon_count[j][k];

            this_pythia.next();
            
//            if (iEvent == 0) this_pythia.process.list();

            // two outgoing guys
            int id1 = this_pythia.process.at(5).id();
            int id2 = this_pythia.process.at(6).id();
            
            ParticleData& data = this_pythia.particleData;
            
            if (data.isQuark(id1)) this_quark_count++;
            if (data.isQuark(id2)) this_quark_count++;
            
            if (data.isGluon(id1)) this_gluon_count++;
            if (data.isGluon(id2)) this_gluon_count++;

         }
         
         if (iEvent % 1000 == 0 ) {
            cout << process_files.at(j) << endl;
            ofstream fout(process_files.at(j) + ".out");
            for (int k = 0; k < num_pt_cuts; k++) {
               cout << pt_cuts.at(k) << " " << quark_count[j][k] / (quark_count[j][k] + gluon_count[j][k]) << endl;
               fout << pt_cuts.at(k) << " " << quark_count[j][k] / (quark_count[j][k] + gluon_count[j][k]) << endl;
            }
         }
         
      }
      
   }
   
   // Done.
   return 0;
}
