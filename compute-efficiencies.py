#!/usr/bin/python
#
# Usage:
#  compute-efficiencies.py <quark-file>.yoda <gluon-file.yoda> <output.yoda>
# 
# produce the efficiency measure from the two yoda files
#
# The output is under the format of another yoda file. At the moment,
# only the average weights are meaningfull.

import sys,math,re,os,yoda

if len(sys.argv) != 4:
    sys.exit("Usage: compute-efficiencies quark.yoda gluon.yoda output.yoda")

# open the files
fileq = open(sys.argv[1]) 
fileg = open(sys.argv[2])
fileo = open(sys.argv[3], "w")

# print what the output looks like
#print "#observable   g^rej_20   g^rej_50   q^rej_20   q^rej_50   s^rej    I1/2    I0'    I1'    I0''    I1''   I1/2''"
print '{0:21s} {1:8s} {2:8s} {3:8s} {4:8s} {5:8s} {6:8s} {7:8s}'.format("#observable","g^rej_20","g^rej_50","q^rej_20","q^rej_50","s^rej","I1/2","I1/2''")

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
# repeatedly look for a "BEGIN" line
while 1:
    # file header
    lineq = read_until_matching(fileq, re.compile("^# BEGIN"));
    lineg = read_until_matching(fileg, re.compile("^# BEGIN"));
    fileo.write(lineq);
    lineq = read_until_matching(fileq, re.compile("^Path="));
    label=lineq.replace("Path=/MC_LHQG_EE/","").rstrip("\n")
    fileo.write(lineq)
    fileo.write("ScaledBy=1.0\n")
    fileo.write("Title=\n")
    fileo.write("Type=Histo1D\n")
    fileo.write("XLabel=\n")
    fileo.write("YLabel=\n")
    fileo.write("# Mean: 0.5 # wrong\n")
    fileo.write("# Area: 1.000000e+0n")
    fileo.write("# ID     ID    sumw    sumw2    sumwx   sumwx2  numEntries\n")
    fileo.write("Total         Total         1.000000e+00      0.000000e+00      0.000000e+00      0.000000e+00      100000\n")
    fileo.write("Underflow     Underflow     0.000000e+00      0.000000e+00      0.000000e+00      0.000000e+00      0\n")
    fileo.write("Overflow      Overflow      0.000000e+00      0.000000e+00      0.000000e+00      0.000000e+00      0\n")
    fileo.write("# xlow        xhigh         sumw              sumw2	         sumwx             sumwx2            numEntries\n")
    lineq = read_until_matching(fileq, re.compile("^# xlow"));
    lineg = read_until_matching(fileg, re.compile("^# xlow"));

    # histogram itself
    lineq=fileq.readline().rstrip()
    lineg=fileg.readline().rstrip()
    pattern_end=re.compile("^# END")

    # initialise the things we need to compute during the histogram browsing
    wtotq=0.0  # for cumulative calculations and overflow calculations
    wtotg=0.0  # for cumulative calculations and overflow calculations
    I05=0.0
    I05_second=0.0
    # I00_prime=0.0
    # I10_prime=0.0
    # I00_second=0.0
    # I10_second=0.0
    qrej20 = 0.0
    qrej50 = 0.0
    grej20 = 0.0
    grej50 = 0.0
    srej   = 0.0
    while not pattern_end.match(lineq):
        # split into columns
        colsq = lineq.split()
        colsg = lineg.split()

        # get the q and g probabilities and compute the quality
        # measure
        #    F=1/2 (Q-G)^2/(Q+G)
        wq = float(colsq[2])
        wg = float(colsg[2])

        w2q = float(colsq[3])
        w2g = float(colsg[3])

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
        # I00_prime +=(  if wq>0 else 0.0)
        # I10_prime +=(  if wq>0 else 0.0)
        # I00_second+=(  if wq>0 else 0.0)
        # I10_second+=(  if wq>0 else 0.0)

        # now we can update the totals
        wtotq += wq
        wtotg += wg

        # update directly in the quark columns
        lo=float(colsq[0])
        q=I05_second_local
        q2=I05_second_local_error
        colsq[2] = str(q)
        colsq[3] = str(q2)
        colsq[4] = str(lo*q) # wrong but not crucial at this stage
        colsq[5] = str(lo*lo*q2) # wrong but not crucial at this stage
        colsq[6] = str(int(100000*q)) # again not ideal

        strsep=" "
        fileo.write(strsep.join(colsq)+"\n")

        # read next entries
        lineq=fileq.readline().rstrip()
        lineg=fileg.readline().rstrip()

    fileo.write(lineq)
    fileo.write("\n")
    
    # overflow contribution:
    wq=1-wtotq
    if (wq<0): wq=0
    wg=1-wtotg
    if (wg<0): wg=0

    I05_second += (0.5*(wq-wg)*(wq-wg)/(wq+wg) if wq+wg>0 else 0.0)

    I05+=(0.5*wq*math.log(2*wq/(wq+wg))/math.log(2.0) if wq>0 else 0.0)
    I05+=(0.5*wg*math.log(2*wg/(wq+wg))/math.log(2.0) if wg>0 else 0.0)
    
    print '{0:21s} {1:8.4f} {2:8.4f} {3:8.4f} {4:8.4f} {5:8.4f} {6:8.4f} {7:8.4f}'.format(label,grej20,grej50,qrej20,qrej50,srej,I05,I05_second)
    
