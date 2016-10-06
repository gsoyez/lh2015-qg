#~/bin/bash

echo "distributions-pp"
gnuplot distributions-pp.gp
echo ""

echo "separations-pp (all MCs)"
gnuplot sep-v-ang-pp.gp
echo ""

echo "variations/modulations-pp"
gnuplot variations-pp.gp
echo ""

echo "Done."
