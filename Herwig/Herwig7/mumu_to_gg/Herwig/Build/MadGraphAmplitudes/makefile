include MG5/Source/make_opts  
PROCESS= InterfaceMadGraph.f   MG5/SubProcesses/P1_mummup_gg/matrix.f\
                   MG5/Source/DHELAS/FFS2_3.f\
                   MG5/Source/DHELAS/VVS3_0.f\
                   MG5/Source/DHELAS/aloha_functions.f\
                   MG5/Source/MODEL/couplings1.f\
                   MG5/Source/MODEL/rw_para.f\
                   MG5/Source/MODEL/printout.f\
                   MG5/Source/MODEL/testprog.f\
                   MG5/Source/MODEL/couplings2.f\
                   MG5/Source/MODEL/couplings.f\
                   MG5/Source/MODEL/model_functions.f\
                   MG5/Source/MODEL/lha_read.f\
                  

all:  
	 gfortran  -g -O2 -w -fbounds-check -ffixed-line-length-132 -fPIC -fno-f2c -shared -s -o  InterfaceMadGraph.so -IMG5/SubProcesses/ -IMG5/SubProcesses/P1_mummup_gg/    $(PROCESS) $(LINKLIBS) 