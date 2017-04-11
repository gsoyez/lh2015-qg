ifeq ($(USER),jthaler)
-include config_jthaler.mk
endif

ifeq ($(USER),larkoski)
-include config_alarkoski.mk
endif

#------------------------------------------------------------------------
# Define compiler
CXX=g++
CXXFLAGS= -O3 -Wall -Woverloaded-virtual -g


#------------------------------------------------------------------------
# Define fastjet flags

FASTJETCONFIG=$(FASTJETLOCATION)/fastjet-config

FJ_CXXFLAGS=$(CXXFLAGS)
FJ_CXXFLAGS += $(shell $(FASTJETCONFIG) --cxxflags  --plugins)

FJ_LDFLAGS=$(LDFLAGS)
FJ_LDFLAGS += -lm $(shell $(FASTJETCONFIG) --libs   --plugins)
FJ_LDFLAGS += -lRecursiveTools -lEnergyCorrelator -lNsubjettiness -lJETJetPlugin

#------------------------------------------------------------------------
# Define pythia flags

INCDIR=include
LIBDIRARCH=lib

PY_CXXFLAGS=$(CXXFLAGS)
PY_CXXFLAGS += -I$(PYTHIA8LOCATION)/$(INCDIR)

PY_LDFLAGS=$(LDFLAGS)
PY_LDFLAGS += -L$(PYTHIA8LOCATION)/$(LIBDIRARCH) -lpythia8

#------------------------------------------------------------------------
# Name executable files
FJ_EXEC=
FJ_EXEC_OBJ=$(FJ_EXEC:=.o)

PY_EXEC=pythia_qg_composition
PY_EXEC_OBJ=$(PY_EXEC:=.o)


#------------------------------------------------------------------------
# compile everything
all: $(FJ_EXEC) $(PY_EXEC)

#------------------------------------------------------------------------
# compiling fastjet executables
$(FJ_EXEC): % : %.o
	$(CXX) $(FJ_CXXFLAGS) $(FJ_LDFLAGS) -o $@ $<

$(FJ_EXEC_OBJ): %.o : %.cc
	$(CXX) $(FJ_CXXFLAGS) -c $<

#------------------------------------------------------------------------
# compiling pythia executables
$(PY_EXEC): % : %.o
	$(CXX) $(PY_CXXFLAGS) $(PY_LDFLAGS) -o $@ $<
	
$(PY_EXEC_OBJ): %.o : %.cc
	$(CXX)  $(PY_CXXFLAGS) -c $<

# cleaning the directory
clean:
	rm -f *~ *.o *.a *.exe
