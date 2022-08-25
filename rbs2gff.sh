#!/bin/bash
#The descriptive crap
if [ -z $1 ]
  then
    echo
    echo "Use this script for getting positions of"
    echo "Ribosome binding sites predicted with rbs_finder.pl"
    echo
    echo "Type the name of your sequence name as it appears in the fastaheader"
    read seq_name
    echo "Type the name of your RBS file"
    read rbs_file
    echo "Type the name of your gff annotation output file"
    read gff_file
  else
    seq_name="$1"
    rbs_file="$2"
    gff_file="$3"
fi
tail -n+3 $rbs_file | awk '{if( $3 < $2 ) print  $5 - 4, $5, ".", "-", ".", "sequence=", $4; else print $5, $5 + 4, ".", "+", ".", "sequence=", $4}' | grep -v "\---" | perl -pe 's/\=\ /\=/; s/\ /\t/g' | perl -pe "s/\l/\l$seq_name\trbs_finder\trbs\t/" | perl -ne 'print ucfirst' > $gff_file
echo "Manually check $gff_file for ambiguities"
echo "Victor Flores 2010"
echo "Department of genetics and molecular biology"
echo "Center for Research and Advanced Studies"
echo "National Polytechnic Institute, Mexico"
exit
