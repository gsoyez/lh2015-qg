# some global setups
#----------------------------------------------------------------------

# BEGIN PLOT /MC_LHQG_@PROC@/
LogY=0
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/GA_10
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/GA_20
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_10
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_20
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_10
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_20
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_10
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_20
Rebin=5
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/GA_.*_R4
Title=@GENLABEL@, R=0.4
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/GA_.*_R6
Title=@GENLABEL@, R=0.6
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/GA_.*_R8
Title=@GENLABEL@, R=0.8
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_.*_R4
Title=@GENLABEL@, R=0.4
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_.*_R6
Title=@GENLABEL@, R=0.6
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_.*_R8
Title=@GENLABEL@, R=0.8
# END PLOT


# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_.*_R4
Title=@GENLABEL@, R=0.4, mMDT($z_{\rm cut}=0.1$)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_.*_R6
Title=@GENLABEL@, R=0.6, mMDT($z_{\rm cut}=0.1$)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_.*_R8
Title=@GENLABEL@, R=0.8, mMDT($z_{\rm cut}=0.1$)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_.*_R4
Title=@GENLABEL@, R=0.4, mMDT($z_{\rm cut}=0.1$)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_.*_R6
Title=@GENLABEL@, R=0.6, mMDT($z_{\rm cut}=0.1$)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_.*_R8
Title=@GENLABEL@, R=0.8, mMDT($z_{\rm cut}=0.1$)
# END PLO
T

# generalised angularities
#----------------------------------------------------------------------
# BEGIN PLOT /MC_LHQG_@PROC@/GA_00_00_Q*
XLabel=$\lambda$($\kappa$=0, $\beta$=0) [multiplicity]
YLabel=1/N dN/d$\lambda$($\kappa$=0, $\beta$=0)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/GA_10_05_Q*
XLabel=$\lambda$($\kappa$=1, $\beta$=1/2)
YLabel=1/N dN/d$\lambda$($\kappa$=1, $\beta$=1/2)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/GA_10_10_Q*
XLabel=$\lambda$($\kappa$=1, $\beta$=1)
YLabel=1/N dN/d$\lambda$($\kappa$=1, $\beta$=1)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/GA_10_20_Q*
XLabel=$\lambda$($\kappa$=1, $\beta$=2)
YLabel=1/N dN/d$\lambda$($\kappa$=1, $\beta$=2)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/GA_20_00_Q*
XLabel=$\lambda$($\kappa$=2, $\beta$=0) [$p_{T,D}^2$]
YLabel=1/N dN/d$\lambda$($\kappa$=2, $\beta$=0)
# END PLOT


# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_00_00_Q*
XLabel=$\lambda$($\kappa$=0, $\beta$=0) [multiplicity]
YLabel=1/N dN/d$\lambda$($\kappa$=0, $\beta$=0)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_10_05_Q*
XLabel=$\lambda$($\kappa$=1, $\beta$=1/2)
YLabel=1/N dN/d$\lambda$($\kappa$=1, $\beta$=1/2)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_10_10_Q*
XLabel=$\lambda$($\kappa$=1, $\beta$=1)
YLabel=1/N dN/d$\lambda$($\kappa$=1, $\beta$=1)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_10_20_Q*
XLabel=$\lambda$($\kappa$=1, $\beta$=2)
YLabel=1/N dN/d$\lambda$($\kappa$=1, $\beta$=2)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/mMDT_GA_20_00_Q*
XLabel=$\lambda$($\kappa$=2, $\beta$=0) [$p_{T,D}^2$]
YLabel=1/N dN/d$\lambda$($\kappa$=2, $\beta$=0)
# END PLOT


# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_00_00_Q*
XLabel=log(1/$\lambda$($\kappa$=0, $\beta$=0)) [multiplicity]
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=0, $\beta$=0)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_10_05_Q*
XLabel=log(1/$\lambda$($\kappa$=1, $\beta$=1/2))
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=1, $\beta$=1/2)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_10_10_Q*
XLabel=log(1/$\lambda$($\kappa$=1, $\beta$=1))
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=1, $\beta$=1)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_10_20_Q*
XLabel=log(1/$\lambda$($\kappa$=1, $\beta$=2))
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=1, $\beta$=2)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_GA_20_00_Q*
XLabel=log(1/$\lambda$($\kappa$=2, $\beta$=0)) [$p_{T,D}^2$]
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=2, $\beta$=0)
# END PLOT



# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_00_00_Q*
XLabel=log(1/$\lambda$($\kappa$=0, $\beta$=0)) [multiplicity]
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=0, $\beta$=0)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_10_05_Q*
XLabel=log(1/$\lambda$($\kappa$=1, $\beta$=1/2))
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=1, $\beta$=1/2)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_10_10_Q*
XLabel=log(1/$\lambda$($\kappa$=1, $\beta$=1))
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=1, $\beta$=1)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_10_20_Q*
XLabel=log(1/$\lambda$($\kappa$=1, $\beta$=2))
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=1, $\beta$=2)
# END PLOT

# BEGIN PLOT /MC_LHQG_@PROC@/log_mMDT_GA_20_00_Q*
XLabel=log(1/$\lambda$($\kappa$=2, $\beta$=0)) [$p_{T,D}^2$]
YLabel=$\lambda$/N dN/d$\lambda$($\kappa$=2, $\beta$=0)
# END PLOT
