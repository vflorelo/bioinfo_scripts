#!/bin/bash
#the input stuff
if [ -z $1 ]
  then
    echo
    echo "Use this script for appending transterm results to a"
    echo "gff annotation file"
    echo "Type the name of your sequence as it appears on the fastaheader"
    read seq_name
    echo "Type the name of your transterm results file"
    read in_file
    echo "Type the name of your gff annotation file"
    read gff_file
    echo "Type the name of your terminator sequences file"
    read term_file
    echo "Type the name of your terminator notes file"
    read notes_file
  else
    seq_name="$1"
    in_file="$2"
    gff_file="$3"
    term_file="$4"
    notes_file="$5"
fi
#naming the sequence
#removing non-informative lines
perl -pe 'if(/TERM/){s/\n/\@/}' $in_file | grep TERM | perl -pe '
s/\-/\ /;
while(/\ \ /){s/\ \ /\ /};
while(/\ /){s/\ /\,/};
s/\l\,/\l/;
s/TERM\,/TERM\_/;
while(/\,\,/){s/\,\,/\,/}
' > temp
#cutting descriptive fields
cut -d\| -f1 temp > temp2
cut -d\| -f2 temp | cut -d\@ -f1 | perl -pe 's/\l\,/\l/; while(/\,/){s/\,/\ /}' > $notes_file
cut -d\@ -f2 temp | perl -pe 's/\l\,/\l/; while(/\,/){s/\,/\ /}' > $term_file
#the first columns of the gff file
software=`echo TransTerm`
feature=`echo terminator`
#cutting informative fields
cut -d\, -f1,2,3,4,6 temp2 > features
grep \- features > minus_terms
grep \+ features > plus_terms
cut -d\, -f2 minus_terms > minus_end
cut -d\, -f3 minus_terms > minus_start
cut -d\, -f2 plus_terms > plus_start
cut -d\, -f3 plus_terms > plus_end
cut -d\, -f4 minus_terms > minus_strand
cut -d\, -f4 plus_terms > plus_strand
cut -d\, -f5 minus_terms > minus_score
cut -d\, -f5 plus_terms > plus_score
cut -d\, -f1 minus_terms > minus_product
cut -d\, -f1 plus_terms > plus_product
#listing the first columns

perl -pe 's/\n/\ /' minus_terms > minus
ARGS=`cat minus`
for count in $ARGS
do
   set -- $count 
   echo "."
done > minus_7_8

for count1 in $ARGS
do
   set -- $count1
   echo "/product="
done > min_product

perl -pe 's/\n/\ /' plus_terms > plus
ARGS1=`cat plus`
for count2 in $ARGS1
do
   set -- $count2
   echo "."
done > plus_7_8

for count3 in $ARGS1
do
   set -- $count3
   echo "/product="
done > pl_product
#the actual assembly
paste minus_start minus_end minus_score minus_strand minus_7_8 minus_7_8 min_product minus_product > minus_features
paste plus_start plus_end plus_score plus_strand plus_7_8 plus_7_8 pl_product plus_product > plus_features
cat minus_features plus_features > all_features
#appending the seq_name to the feature table
perl -pe 'while(/\t/){s/\t/\_/}; s/\n/\ /' all_features > all
ARGS2=`cat all`
for count4 in $ARGS2
do
   set -- $count4
   echo "$seq_name	$software	$feature"
done > seq_soft_feat
paste seq_soft_feat all_features | perl -pe 's/\=\t/\=/' > $gff_file
#removing the crap
rm temp* features all all_features minus* plus* min_product pl_product seq_soft_feat
#and the credits
echo "Manually check $gff_file, $term_file and $notes_file for ambiguities"
echo "Victor Missael Flores López 2010"
echo "Department of genetics and molecular biology"
echo "Center for Research and Advanced Studies"
echo "National Polytechnic Institute, Mexico"
exit
