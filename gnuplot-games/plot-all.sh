#~/bin/bash

echo "distributions"
gnuplot distributions.gp
echo ""

echo "separations (all MCs)"
gnuplot sep-v-ang.gp
echo ""

echo "separations (individual MCs)"
gnuplot sep-v-ang-mcs.gp
echo ""

echo "variations/modulations"
gnuplot variations.gp
echo ""

echo "Done."
