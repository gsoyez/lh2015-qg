#!/usr/bin/python
#
# Usage:
#  compute-efficiencies-pp.py <zjet-file>.yoda <dijet-file.yoda> <output.yoda>
# 
# produce the efficiency measure from the two yoda files
#
# The output is under the format of another yoda file. At the moment,
# only the average weights are meaningfull.

import sys,math,re,os,yoda

if len(sys.argv) != 4:
    sys.exit("Usage: compute-efficiencies-pp-new.py Zjet.yoda dijet.yoda output.yoda")

# open the files
all_zj = yoda.read(sys.argv[1]) 
all_jj = yoda.read(sys.argv[2])

# print what the output looks like
print '{0:21s} {1:8s} {2:8s} {3:8s} {4:8s} {5:8s} {6:8s} {7:8s}'.format("#observable","jj^rej_20","jj^rej_50","zj^rej_20","zj^rej_50","s^rej","I1/2","I1/2''")

#------------------------------------------------------------------------
# a couple of helpers

# read from a file until the line matched a pattern 
def read_until_matching(fin, pattern):
    line=""
    while not pattern.match(line):
        line=fin.readline()
        if not line: sys.exit()
    return line

# read from a file until the line matched a pattern
# in the process, print every line to the output file
def read_until_matching_and_print(fin, pattern, fout):
    line=""
    while not pattern.match(line):
        line=fin.readline()
        if not line: sys.exit()
        fout.write(line);
    return line


#------------------------------------------------------------------------
# browse entries in the Z+jet file
pattern = re.compile(".*GA.*")

all_sep=[]
for obs_zj in all_zj.itervalues():
    # get the path
    path_zj = obs_zj.path
    if not pattern.match(path_zj):
        continue

    # find matching observable in the jj file
    label=path_zj.replace("/MC_LHQG_Zjet/","").rstrip("\n")
    expected_path_jj = path_zj.replace('Zjet','dijet')
    for obs_jj in all_jj.itervalues():
        if (obs_jj.path == expected_path_jj):
            break

    obs_sep = obs_zj.clone()
    obs_sep.reset()
    
    # initialise the things we need to compute during the histogram browsing
    wtotq=0.0  # for cumulative calculations and overflow calculations
    wtotg=0.0  # for cumulative calculations and overflow calculations
    I05=0.0
    I05_second=0.0
    qrej20 = 0.0
    qrej50 = 0.0
    grej20 = 0.0
    grej50 = 0.0
    srej   = 0.0
    for ibin in range(obs_zj.numBins):
        # get the q and g probabilities and compute the quality
        # measure
        #    F=1/2 (Q-G)^2/(Q+G)
        wq = obs_zj.bin(ibin).area
        wg = obs_jj.bin(ibin).area

        w2q = obs_zj.bin(ibin).areaErr*obs_zj.bin(ibin).areaErr
        w2g = obs_jj.bin(ibin).areaErr*obs_jj.bin(ibin).areaErr
    
        # check if we cross one of the interesting percentiles
    
        # test the cut "observed < cut" for 20%
        if wtotq<=0.2 and wtotq+wq>0.2:
            f=(0.2-wtotq)/wq
            grej=1-(wtotg+f*wg)
            if grej>grej20: grej20=grej
            
        if wtotg<=0.2 and wtotg+wg>0.2:
            f=(0.2-wtotg)/wg
            qrej=1-(wtotq+f*wq)
            if qrej>qrej20: qrej20=qrej
    
        # test the cut "observed < cut" or "observed > cut" for 50%
        if wtotq<=0.5 and wtotq+wq>0.5:
            f=(0.5-wtotq)/wq
            grej50=max(1-(wtotg+f*wg),wtotg+f*wg)
    
        if wtotg<=0.5 and wtotg+wg>0.5:
            f=(0.5-wtotg)/wg
            qrej50=max(1-(wtotq+f*wq),wtotq+f*wq)
    
        # test the cut "observed > cut" for 20%
        if wtotq<=0.8 and wtotq+wq>0.8:
            f=(0.8-wtotq)/wq
            grej=(wtotg+f*wg)
            if grej>grej20: grej20=grej
            
        if wtotg<=0.8 and wtotg+wg>0.8:
            f=(0.8-wtotg)/wg
            qrej=(wtotq+f*wq)
            if qrej>qrej20: qrej20=qrej
    
        # check the symmetric rejection. This corresponds to Q+G=1
        if wtotq+wtotg<=1 and wtotq+wtotg+wq+wg>1:
            f=(1-wtotq-wtotg)/(wq+wg)
            srej=max(wtotq+f*wq, wtotg+f*wg)
    
        # compute the measures based on mutual info
        I05_second_local=0.5*(wq-wg)*(wq-wg)/(wq+wg) if wq+wg>0 else 0.0
        I05_second += I05_second_local
        
        I05_second_local_error=0.25*(wq-wg)*(wq-wg) \
         *(w2q*(3.0*wg+wq)*(3.0*wg+wq)+w2g*(wg+3.0*wq)*(wg+3.0*wq)) \
         /((wq+wg)*(wq+wg)*(wq+wg)*(wq+wg)) if wq+wg>0 else 0.0
    
        I05+=(0.5*wq*math.log(2*wq/(wq+wg))/math.log(2.0) if (wq>0 and wg+wq>0) else 0.0)
        I05+=(0.5*wg*math.log(2*wg/(wq+wg))/math.log(2.0) if (wg>0 and wg+wq>0) else 0.0)
    
        # now we can update the totals
        wtotq += wq
        wtotg += wg
    
        # update directly in the quark columns
        q=I05_second_local
        q2=I05_second_local_error
        obs_sep.fillBin(ibin,0.5*(q+math.sqrt(2*q2+q*q)))
        obs_sep.fillBin(ibin,0.5*(q-math.sqrt(2*q2+q*q)))
    
    all_sep.append(obs_sep)
        
    # overflow contribution:
    wq=1-wtotq
    if (wq<0): wq=0
    wg=1-wtotg
    if (wg<0): wg=0
    
    I05_second += (0.5*(wq-wg)*(wq-wg)/(wq+wg) if wq+wg>0 else 0.0)
    
    I05+=(0.5*wq*math.log(2*wq/(wq+wg))/math.log(2.0) if wq>0 else 0.0)
    I05+=(0.5*wg*math.log(2*wg/(wq+wg))/math.log(2.0) if wg>0 else 0.0)
    
    print '{0:30s} {1:8.4f} {2:8.4f} {3:8.4f} {4:8.4f} {5:8.4f} {6:8.4f} {7:8.4f}'.format(label,grej20,grej50,qrej20,qrej50,srej,I05,I05_second)

yoda.writeYODA(all_sep,sys.argv[3])
    
    
    # # file header
    # lineq = read_until_matching(fileq, re.compile("^BEGIN YODA_HISTO1D /MC_LHQG|^# BEGIN YODA_HISTO1D /MC_LHQG"));
    # lineg = read_until_matching(fileg, re.compile("^BEGIN YODA_HISTO1D /MC_LHQG|^# BEGIN YODA_HISTO1D /MC_LHQG"));
    # print lineq
    # print lineg
    # fileo.write(lineq);
    # lineq = read_until_matching(fileq, re.compile("^Path="));
    # print lineq
    # #lineq=lineq.replace("Path=/MC_LHQG_EE/","")
    # #lineq=lineq.replace("Path=/MC_LHQG_dijet/","")
    # #label=lineq.replace("Path=/MC_LHQG_Zjet/","").rstrip("\n")
    # #fileo.write(lineq)
    # fileo.write(lineq)
    # label=lineq.replace("Path=/MC_LHQG_Zjet/","").rstrip("\n")
    # print label
    # 
    # fileo.write("ScaledBy=1.0\n")
    # fileo.write("Title=\n")
    # fileo.write("Type=Histo1D\n")
    # fileo.write("XLabel=\n")
    # fileo.write("YLabel=\n")
    # fileo.write("# Mean: 0.5\n")
    # fileo.write("# Area: 1.000000e+00\n")
    # fileo.write("# ID     ID    sumw    sumw2    sumwx   sumwx2  numEntries\n")
    # fileo.write("Total         Total         1.000000e+00      1.000000e+00      1.000000e+00      1.000000e+00      100000\n")
    # fileo.write("Underflow     Underflow     0.000000e+00      0.000000e+00      0.000000e+00      0.000000e+00      0\n")
    # fileo.write("Overflow      Overflow      0.000000e+00      0.000000e+00      0.000000e+00      0.000000e+00      0\n")
    # fileo.write("# xlow        xhigh         sumw              sumw2	         sumwx             sumwx2            numEntries\n")
    # lineq = read_until_matching(fileq, re.compile("^# xlow"));
    # lineg = read_until_matching(fileg, re.compile("^# xlow"));
    # 
    # # histogram itself
    # lineq=fileq.readline().rstrip()
    # lineg=fileg.readline().rstrip()
    # pattern_end=re.compile("^END|^# END")
    # 
    # # initialise the things we need to compute during the histogram browsing
    # wtotq=0.0  # for cumulative calculations and overflow calculations
    # wtotg=0.0  # for cumulative calculations and overflow calculations
    # I05=0.0
    # I05_second=0.0
    # # I00_prime=0.0
    # # I10_prime=0.0
    # # I00_second=0.0
    # # I10_second=0.0
    # qrej20 = 0.0
    # qrej50 = 0.0
    # grej20 = 0.0
    # grej50 = 0.0
    # srej   = 0.0
    # while not pattern_end.match(lineq):
    #     # split into columns
    #     colsq = lineq.split()
    #     colsg = lineg.split()
    # 
    #     # get the q and g probabilities and compute the quality
    #     # measure
    #     #    F=1/2 (Q-G)^2/(Q+G)
    #     wq = float(colsq[2])
    #     wg = float(colsg[2])
    # 
    #     w2q = float(colsq[3])
    #     w2g = float(colsg[3])
    # 
    #     # check if we cross one of the interesting percentiles
    # 
    #     # test the cut "observed < cut" for 20%
    #     if wtotq<=0.2 and wtotq+wq>0.2:
    #         f=(0.2-wtotq)/wq
    #         grej=1-(wtotg+f*wg)
    #         if grej>grej20: grej20=grej
    #         
    #     if wtotg<=0.2 and wtotg+wg>0.2:
    #         f=(0.2-wtotg)/wg
    #         qrej=1-(wtotq+f*wq)
    #         if qrej>qrej20: qrej20=qrej
    # 
    #     # test the cut "observed < cut" or "observed > cut" for 50%
    #     if wtotq<=0.5 and wtotq+wq>0.5:
    #         f=(0.5-wtotq)/wq
    #         grej50=max(1-(wtotg+f*wg),wtotg+f*wg)
    # 
    #     if wtotg<=0.5 and wtotg+wg>0.5:
    #         f=(0.5-wtotg)/wg
    #         qrej50=max(1-(wtotq+f*wq),wtotq+f*wq)
    # 
    #     # test the cut "observed > cut" for 20%
    #     if wtotq<=0.8 and wtotq+wq>0.8:
    #         f=(0.8-wtotq)/wq
    #         grej=(wtotg+f*wg)
    #         if grej>grej20: grej20=grej
    #         
    #     if wtotg<=0.8 and wtotg+wg>0.8:
    #         f=(0.8-wtotg)/wg
    #         qrej=(wtotq+f*wq)
    #         if qrej>qrej20: qrej20=qrej
    # 
    #     # check the symmetric rejection. This corresponds to Q+G=1
    #     if wtotq+wtotg<=1 and wtotq+wtotg+wq+wg>1:
    #         f=(1-wtotq-wtotg)/(wq+wg)
    #         srej=max(wtotq+f*wq, wtotg+f*wg)
    # 
    #     # compute the measures based on mutual info
    #     I05_second_local=0.5*(wq-wg)*(wq-wg)/(wq+wg) if wq+wg>0 else 0.0
    #     I05_second += I05_second_local
    #     
    #     I05_second_local_error=0.25*(wq-wg)*(wq-wg) \
    #      *(w2q*(3.0*wg+wq)*(3.0*wg+wq)+w2g*(wg+3.0*wq)*(wg+3.0*wq)) \
    #      /((wq+wg)*(wq+wg)*(wq+wg)*(wq+wg)) if wq+wg>0 else 0.0
    # 
    #     I05+=(0.5*wq*math.log(2*wq/(wq+wg))/math.log(2.0) if (wq>0 and wg+wq>0) else 0.0)
    #     I05+=(0.5*wg*math.log(2*wg/(wq+wg))/math.log(2.0) if (wg>0 and wg+wq>0) else 0.0)
    #     # I00_prime +=(  if wq>0 else 0.0)
    #     # I10_prime +=(  if wq>0 else 0.0)
    #     # I00_second+=(  if wq>0 else 0.0)
    #     # I10_second+=(  if wq>0 else 0.0)
    # 
    #     # now we can update the totals
    #     wtotq += wq
    #     wtotg += wg
    # 
    #     # update directly in the quark columns
    #     lo=float(colsq[0])
    #     q=I05_second_local
    #     q2=I05_second_local_error
    #     colsq[2] = str(q)
    #     colsq[3] = str(q2)
    #     colsq[4] = str(lo*q) # wrong but not crucial at this stage
    #     colsq[5] = str(lo*lo*q2) # wrong but not crucial at this stage
    #     colsq[6] = str(int(100000*q)) # again not ideal
    # 
    #     strsep=" "
    #     fileo.write(strsep.join(colsq)+"\n")
    # 
    #     # read next entries
    #     lineq=fileq.readline().rstrip()
    #     lineg=fileg.readline().rstrip()
    # 
    # fileo.write(lineq)
    # fileo.write("\n")
    # fileo.write("\n")
    # 
    # # overflow contribution:
    # wq=1-wtotq
    # if (wq<0): wq=0
    # wg=1-wtotg
    # if (wg<0): wg=0
    # 
    # I05_second += (0.5*(wq-wg)*(wq-wg)/(wq+wg) if wq+wg>0 else 0.0)
    # 
    # I05+=(0.5*wq*math.log(2*wq/(wq+wg))/math.log(2.0) if wq>0 else 0.0)
    # I05+=(0.5*wg*math.log(2*wg/(wq+wg))/math.log(2.0) if wg>0 else 0.0)
    # 
    # print '{0:21s} {1:8.4f} {2:8.4f} {3:8.4f} {4:8.4f} {5:8.4f} {6:8.4f} {7:8.4f}'.format(label,grej20,grej50,qrej20,qrej50,srej,I05,I05_second)
    


# yoda.writeYODA(obs_vector,sys.argv[3])
    
