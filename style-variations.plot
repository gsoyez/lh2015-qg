# some global setups
#----------------------------------------------------------------------

# BEGIN PLOT /MC_LHQG_EE/
LogY=0
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/GA_10
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/GA_20
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_10
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_20
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/GA_.*_R3
Title=@GENLABEL@, R=0.3
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/GA_.*_R6
Title=@GENLABEL@, R=0.6
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/GA_.*_R9
Title=@GENLABEL@, R=0.9
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_.*_R3
Title=@GENLABEL@, R=0.3
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_.*_R6
Title=@GENLABEL@, R=0.6
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_.*_R9
Title=@GENLABEL@, R=0.9
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/Thrust
Title=@GENLABEL@
# END PLOT


# generalised angularities
#----------------------------------------------------------------------
# BEGIN PLOT /MC_LHQG_EE/GA_00_00_R*
XLabel=$\lambda$($\kappa$=0, $\beta$=0) [multiplicity]
YLabel=1/N dN/d$\lambda$($\kappa$=0, $\beta$=0)
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/GA_10_05_R*
XLabel=$\lambda$($\kappa$=1, $\beta$=1/2)
YLabel=1/N dN/d$\lambda$($\kappa$=1, $\beta$=1/2)
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/GA_10_10_R*
XLabel=$\lambda$($\kappa$=1, $\beta$=1)
YLabel=1/N dN/d$\lambda$($\kappa$=1, $\beta$=1)
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/GA_10_20_R*
XLabel=$\lambda$($\kappa$=1, $\beta$=2)
YLabel=1/N dN/d$\lambda$($\kappa$=1, $\beta$=2)
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/GA_20_00_R*
XLabel=$\lambda$($\kappa$=2, $\beta$=0) [$p_{T,D}^2$]
YLabel=1/N dN/d$\lambda$($\kappa$=2, $\beta$=0)
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_00_00_R*
XLabel=log(1/$\lambda$($\kappa$=0, $\beta$=0)) [multiplicity]
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=0, $\beta$=0)
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_10_05_R*
XLabel=log(1/$\lambda$($\kappa$=1, $\beta$=1/2))
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=1, $\beta$=1/2)
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_10_10_R*
XLabel=log(1/$\lambda$($\kappa$=1, $\beta$=1))
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=1, $\beta$=1)
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_10_20_R*
XLabel=log(1/$\lambda$($\kappa$=1, $\beta$=2))
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=1, $\beta$=2)
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/log_GA_20_00_R*
XLabel=log(1/$\lambda$($\kappa$=2, $\beta$=0)) [$p_{T,D}^2$]
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=2, $\beta$=0)
# END PLOT

#----------------------------------------------------------------------
# thrust lin and log scales
#----------------------------------------------------------------------
# BEGIN PLOT /MC_LHQG_EE/Thrust
XLabel=T (Thrust)
YLabel=1/N dN/dT
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/Thrust_log
XLabel=log(1-T) [T=Thrust]
YLabel=T/N dN/dT
XMin=-8.0
Rebin=5
# END PLOT

#----------------------------------------------------------------------
# multiplicities in bins of thrust
#----------------------------------------------------------------------
# BEGIN PLOT /MC_LHQG_EE/MultHadronThrust
Title=@GENLABEL@, low thrust (hadronisation region)
XLabel=multiplicity
YLabel=1/N dN/dmultiplicity
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/MultIntermediasThrust
Title=@GENLABEL@, intermediate thrust (intermediate region)
XLabel=multiplicity
YLabel=1/N dN/dmultiplicity
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/MultShowerThrust
Title=@GENLABEL@, large thrust (shower region)
XLabel=multiplicity
YLabel=1/N dN/dmultiplicity
# END PLOT

# BEGIN PLOT /MC_LHQG_EE/MultHardThrust
Title=@GENLABEL@, very large thrust (hard region)
XLabel=multiplicity
YLabel=1/N dN/dmultiplicity
# END PLOT

