#!/usr/bin/perl -w
#
# script for rebinning something in our standard histogram format:
#    lo mid hi val1 val2 val3 ...
#
# OR with -1 option, format
#    mid val1 val2 val3 ...
#
#----------------------------------
# Usage:
#   rebin.pl [-c ncomb] [-1] [-2] [-a] [-r] [-v]  [-l lo] [-h hi] [filename]
#
#   -c ncomb indicates how many bins to recombine (default 5)
#
#   -v       indicates verbose output
#
#   -r       renormalise the bin contents (i.e. they are dn/dx rather 
#            than dn/dbin)
#
#   -a       write out cumulative results rather than differential ones
#            [with -r option, results become (int^X dn/dx dx); assumes
#            uniform bin spacing, and gives an error together with -1]
#
#   -1       input histograms have just one column of x values (default 
#            assumes 3), i.e. bin center
#
#   -2       input histograms have two cols of x values (low and high)
#
#   -l lo    start binning from lo value
#   -h hi    stop binning from hi value
# 
#   -e errcol1[,errcol2[,...]
#            comma-separate list of columns that are actually error-columns,
#            for which result should be sqrt(sum-of-squares).
#
#   filename indicates the input filename (in absence, read from STDIN).

use Getopt::Std;

$ncomb=5;
$count=0;
$binlocol=0;
$binhicol=2;

# record command-line
print STDOUT "# $0 ".join(" ",@ARGV)."\n";

%options=();
getopts("rvac:123l:h:e:",\%options);

# deal with the options
$verbose = defined $options{"v"};
$renorm = defined $options{"r"};
$ncomb = $options{"c"} if defined $options{"c"};
$lolim = $options{"l"} ? $options{"l"} : -1e300;
$hilim = $options{"h"} ? $options{"h"} :  1e300;
$errcol = $options{"e"} ? $options{"e"} :  "";
$accumulate = defined $options{"a"};
if (defined $options{"1"}) {$binhicol = 0;}
if (defined $options{"2"}) {$binhicol = 1;}
if (defined $options{"3"}) {$binhicol = 2;}

# turn the comma-separated list of error columns into a 
# hash.
@errcol = split(",",$errcol);
%errcol = ();
foreach $errcol (@errcol) {$errcol{$errcol-1} = 1;};

# get the normalisation factor in front of summed bins
$norm = $renorm ? 1.0/$ncomb : 1.0;

# now allow for a filename
my $handle;
if ($ARGV[0]) {
  $filename = $ARGV[0];
  open($handle, "<$filename") || die "Could not open $filename";
  print STDERR "Reading from $filename\n" if ($verbose) ;
} else {
  $handle = STDIN;
  print STDERR "Reading from STDIN\n" if ($verbose) ;
}

# provide some helpful output
print STDERR "Will combine groups of $ncomb bins\n" if ($verbose) ;
print STDERR "Assuming ",$binhicol-$binlocol+1," column(s) of x information\n" if $verbose;
print STDERR "Normalisation factor = $norm\n" if $verbose;

my $binlo;
my $binhi;
my @bins;
my $atstart = 1;
while ($line=<$handle>) {
  # stop accumulating when we see a blank line or a #
  # or a line starting with text
  if ($line =~ /^\s*\#/ || $line =~ /^\s*$/ || $line =~ /^[a-z]/i) {
    print $line; 
    $count = 0; # reset counters
    $atstart = 1;
    next;
  }
  @cols=split(" ",$line);
  # allow ourselves an escape clause
  if ($cols[$binlocol] < $lolim ||  $cols[$binhicol] > $hilim) {next;}
  # now get going
  $count++;
  if ($count == 1) {
    # reset things
    $binlo = $cols[$binlocol];
    $ncol = $#cols - $binhicol;
    # rethink the normalisation
    if ($atstart && $accumulate && $renorm) {
      if ($binhicol == $binlocol) {die "Cannot accumulate and renormalise for 1-column data";}
      $norm = $cols[$binhicol] - $cols[$binlocol];
      print STDERR "Reset normalisation factor = $norm\n" if $verbose;
    }
    # fill up zero-bins
    for ($i=0; $i < $ncol; $i++) {
      if ((!$accumulate) || $atstart) {$bins[$i] = 0;}
    }
    $atstart = 0;
  }

  # accumulate results
  for ($i=0; $i < $ncol; $i++) {
    $icol = $i+$binhicol+1; # physical colum (starting 0)
    $val = $cols[$icol];
    $bins[$i] += $errcol{$icol} ? $val**2 : $val;
  }

  # end a line and write out
  if ($count == $ncomb) {
    $binhi = $cols[$binhicol];
    if ($binhicol == $binlocol) {
      print 0.5*($binlo+$binhi), " ";
    } else {
      print $binlo, " ", 0.5*($binlo+$binhi), " ",$binhi," ";
    }
    for ($i=0; $i < $ncol; $i++) {
      $icol = $i+$binhicol+1; # physical colum (starting 0)
      $res = $errcol{$icol} ? sqrt($bins[$i]) : $bins[$i];
      print $norm * $res," ";
    }
    print "\n";
    $count = 0;
  }
}


