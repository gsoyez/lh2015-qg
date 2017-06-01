#!/bin/bash

mkdir quarkgluon_v3
mkdir quarkgluon_v3/figures/

cp quarkgluon_jhep.tex quarkgluon_v3/
cp quarkgluon_jhep.bbl quarkgluon_v3/
cp jheppub.sty quarkgluon_v3/

pushd figures
for file in *.pdf
do
   echo $file
   cp $file ../quarkgluon_v3/figures/$file
done
popd

pushd quarkgluon_v3/figures
for file in *.pdf
do
   echo $file
   mv $file $file.old
   ps2pdf $file.old $file
   rm $file.old
done
popd

tar cvzf quarkgluon_v3.tgz quarkgluon_v3/

pushd quarkgluon_v3
pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
popd
