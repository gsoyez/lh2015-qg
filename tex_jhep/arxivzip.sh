#!/bin/bash

mkdir quarkgluon_v2
mkdir quarkgluon_v2/figures/

cp quarkgluon_jhep.tex quarkgluon_v2/
cp quarkgluon_jhep.bbl quarkgluon_v2/
cp jheppub.sty quarkgluon_v2/

pushd figures
for file in *.pdf
do
   echo $file
   cp $file ../quarkgluon_v2/figures/$file
done
popd

pushd quarkgluon_v2/figures
for file in *.pdf
do
   echo $file
   mv $file $file.old
   ps2pdf $file.old $file
   rm $file.old
done
popd

tar cvzf quarkgluon_v2.tgz quarkgluon_v2/

pushd quarkgluon_v2
pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
popd
