reset
set term pdfcairo color font ",12" size 8cm,7cm
set colors classic

set xlabel 'R E_J [GeV]'
set xrange [4:500]
set xtics add ("5" 5, "50" 50, "500" 500)
set logscale x

set log y

set bars small


set key at graph 0.97,0.9 maxrows 2 width -5.5
set label 1 'MC'            center at graph 0.69,0.93
set label 2 '{/Symbol e}_0' center at graph 0.87,0.93

CF=4.0/3.0
CA=3.0

langle='<'
rangle='>'

omega0=0.225549
xi0=0.367883

f(RE,beta,Ci)=1.0/(beta-1)*(omega0*Ci/RE)*(1-(xi0*Ci/RE)**(beta-1))

mc(beta)=sprintf("< cat ../Pythia-8205/averages.dat ../Herwig-2_7_1/averages.dat ../Sherpa-2.1.1/averages.dat ../Vincia-1201/averages.dat ../Deductor-1.0.2/averages.dat ../Ariadne/averages.dat ../Dire-1.0.0/averages.dat | awk -v beta=%g '{if ($3<beta-0.01){next;}if ($3>beta+0.01){next;} print 0.5*$1*$2,$6-$4,$7-$5}' | sort -nk1 | awk 'BEGIN{prev=0;minq=100.0;maxq=0.0;ming=100.0;maxg=0.0}{if ($1>prev){if (prev>0){print prev,minq,maxq,ming,maxg;}minq=100.0;maxq=0.0;ming=100.0;maxg=0.0}if($2<minq){minq=$2}if($2>maxq){maxq=$2}if($3<ming){ming=$3}if($3>maxg){maxg=$3};prev=$1}END{print prev,minq,maxq,ming,maxg;}'",beta)

splitfactor=1.02

betas="0.5 1 2"

set lmargin at screen 0.2
set rmargin at screen 0.96
set bmargin at screen 0.16
set tmargin at screen 0.98

do for [ib=1:words(betas)]{
    beta = word(betas,ib)
    set out 'np-shift-beta'.beta.'.pdf' 
    set ylabel langle.'e@_{'.beta.'}^{NP}'.rangle offset beta+0.5
    set label 10 '{/*1.1 {/Symbol b}='.beta.'}' at graph 0.07,0.9
    set ytics auto
    if (ib==1){ set yrange [0.02:1];   set ytics add ("0.02" 0.02, "0.05" 0.05, "0.2" 0.2, "0.5" 0.5)}
    if (ib==2){ set yrange [0.002:1];  set ytics add ("0.002" 0.002)}
    if (ib==3){ set yrange [0.0001:1];}
    plot mc(beta+0.0) u ($1/splitfactor):(0.5*($4+$5)):4:5 t 'gluon' w yerr dt 1 lc 3             lw 2 ps 0,\
         mc(beta+0.0) u ($1*splitfactor):(0.5*($2+$3)):2:3 t 'quark' w yerr dt 1 lc rgb '#00aa00' lw 2 ps 0,\
         f(x,beta+0.00001,CA) t ' ' w l dt 2 lc 3             lw 3,\
         f(x,beta+0.00001,CF) t ' ' w l dt 2 lc rgb '#00aa00' lw 3
}

set out

