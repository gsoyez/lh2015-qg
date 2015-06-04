#!/usr/bin/python
#
# Usage:
#  compute-efficiencies.py <quark-file>.yoda <gluon-file.yoda> <output.yoda>
# 
# produce the efficiency measure from the two yoda files
#
# The output is under the format of another yoda file. At the moment,
# only the average weights are meaningfull.

import sys,math,re

if len(sys.argv) != 4:
    sys.exit("Usage: compute-efficiencies quark.yoda gluon.yoda output.yoda")

# open the files
fileq = open(sys.argv[1]) 
fileg = open(sys.argv[2])
fileo = open(sys.argv[3], "w")


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
    label=lineq.rstrip("\n")
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
    total_quality=0.0
    wqtot=0.0
    wgtot=0.0
    while not pattern_end.match(lineq):
        # split into columns
        colsq = lineq.split()
        colsg = lineg.split()

        # get the q and g probabilities and compute the quality
        # measure
        #    F=1/2 (Q-G)^2/(Q+G)
        pq = float(colsq[2])
        pg = float(colsg[2])
        lo=float(colsq[0])
        hi=float(colsq[1])
        quality=0.0
        wqtot += pq
        wgtot += pg
        if pq+pg>0: quality = 0.5*(pq-pg)*(pq-pg)/(pq+pg) 
            #quality = 0.5*((pq-pg)*(pq-pg)-(pq+pg)*(pq+pg))/(pq+pg) 
        total_quality += quality
            
        # update directly in the quark columns
        colsq[2] = str(quality)
        colsq[3] = str(quality) # wrong but not crucial at this stage
        colsq[4] = str(lo*quality) # wrong but not crucial at this stage
        colsq[5] = str(lo*lo*quality) # wrong but not crucial at this stage
        colsq[6] = str(int(100000*quality)) # again not ideal

        strsep=" "
        fileo.write(strsep.join(colsq)+"\n")

        # read next entries
        lineq=fileq.readline().rstrip()
        lineg=fileg.readline().rstrip()

    fileo.write(lineq)
    fileo.write("\n")
    # overflow contribution:
    pq=1-wqtot
    if (pq<0): pq=0
    pg=1-wgtot
    if (pg<0): pg=0
    if pq+pg>0: total_quality += 0.5*(pq-pg)*(pq-pg)/(pq+pg) 
    
    print label+": "+str(total_quality)
    
