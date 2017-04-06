#!/bin/bash

mkdir quarkgluon_v1
mkdir quarkgluon_v1/figures/

cp quarkgluon_jhep.tex quarkgluon_v1/
cp quarkgluon_jhep.bbl quarkgluon_v1/
cp jheppub.sty quarkgluon_v1/

pushd figures
for file in *.pdf
do
   echo $file
   cp $file ../quarkgluon_v1/figures/$file
done
popd

pushd quarkgluon_v1/figures
for file in *.pdf
do
   echo $file
   mv $file $file.old
   ps2pdf $file.old $file
   rm $file.old
done
popd

tar cvzf quarkgluon_v1.tgz quarkgluon_v1/

pushd quarkgluon_v1
pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
pdflatex --file-line-error --synctex=1 quarkgluon_jhep.tex
popd
