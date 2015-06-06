#!/bin/bash
#
# Extract a number from a separation table
#
# Note: separation tables are the stdout output of
#       compute-efficiencies.py
#
# Usage:
#
#  get-separation file observable measure
#
# where measure is one of grej20 grej50 qrej20 qrej50 srej I I2

if [ "$#" -ne 3 ]; then
    >&2 echo "usage: get-separation file observable measure"
    exit
fi

if [ ! -f $1 ]; then
    >&2 echo "get-separation.sh: file $1 not found"
    exit
fi

line=`grep ^$2 $1`
if [ -z "$line" ]; then
    >&2 echo "get-separation.sh: observable $2 not found in file $1"
    exit
fi

col=0
case $3 in
    grej20)
        col=2
        ;;
    grej50)
        col=3
        ;;
    qrej20)
        col=4
        ;;
    qrej50)
        col=5
        ;;
    srej)
        col=6
        ;;
    I)
        col=7
        ;;
    I2)
        col=8
        ;;
    *)
        >&2 echo "get-separation.sh: measure has to be one of grej20 grej50 qrej20 qrej50 srej I I2"
        exit
        ;;
esac

echo $line | awk -v col=$col '{ print $col}'
