#!/bin/bash

mkdir quarkgluon_v2p5
mkdir quarkgluon_v2p5/figures/

cp quarkgluon_jhep.tex quarkgluon_v2p5/
cp quarkgluon_jhep.bbl quarkgluon_v2p5/
cp jheppub.sty quarkgluon_v2p5/

pushd figures
for file in *.pdf
do
   echo $file
   cp $file ../quarkgluon_v2p5/figures/$file
done
popd

pushd quarkgluon_v2p5/figures
for file in *.pdf
do
   echo $file
   mv $file $file.old
   ps2pdf $file.old $file
   rm $file.old
done
popd

tar cvzf quarkgluon_v2p5.tgz quarkgluon_v2p5/

#pushd quarkgluon_v2p5
#pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
#pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
#pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
#popd
