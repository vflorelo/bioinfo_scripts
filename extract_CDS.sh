#!/bin/bash
###Prepare fasta files containing nucleotide and aminoacid sequences of coding regions from gbk files
###Process one file at a time. So it can be put into a loop
gbk_file=$1
definition=`grep -wA1 DEFINITION $gbk_file | grep -wv ACCESSION | perl -pe "s/\n//g;s/\bDEFINITION\b//g;s/ +/ /g;s/^\ //;
s/\bDNA\b//g;
s/\bcomplete\b//g;
s/\bgenome\b//g;
s/\bisolate\b//g;
s/\bmutant\b//g;
s/\bmain\b//g;
s/\bstr\b//g;
s/\bstrain\b//g;
s/\bsubstrain\b//g;
s/\bclone\b//g;
s/\ /_/g;s/\,/_/g;s/\:/_/g;s/\;/_/g;s/\#/_/g;s/\'/_/g;s/\(/_/g;s/\)/_/g;s/\=/_/g;s/\-/_/g;s/\//_/g;s/\./_/g;s/_+/_/g;s/_$//"`
base_name=`echo $gbk_file | perl -pe 's/\.gb.*//'`
accession=`grep -w -m1 ACCESSION $gbk_file | awk '{print $2}'`
gff_file="$base_name.gff"
fna_file="$base_name.fna"
faa_file="$base_name.faa"
ffn_file="$base_name.ffn"
seqret -feature -sequence $gbk_file gff::$gff_file
seqret -sequence $gbk_file fasta::$fna_file
perl -pi -e "s/\>.*/\>$accession\ $definition/" $fna_file
echo "`awk '{if($3=="CDS"){print $AF}}' $gff_file `" > $gff_file
####In case of introns/frameshifts, get the IDs of the CDS not to be included in the following line
grep "Parent=" $gff_file | cut -f 9 | cut -d\= -f2 | sort | uniq > $base_name.fs_intron_cds
grep -wvFf $base_name.fs_intron_cds $gff_file | perl -pe "s/\tID\=/\t/;s/\;.*product\=/\t/g;s/\;.*//;s/ +/ /g;s/^\ //;s/\ /_/g;s/\,/_/g;s/\:/_/g;s/\;/_/g;s/\#/_/g;s/\'/_/g;s/\(/_/g;s/\)/_/g;s/\=/_/g;s/\//_/g;s/_+/_/g;s/_$//" | awk -v definition="$definition" 'BEGIN{FS="\t"} {if($7=="-"){print $9"@"definition"@"$10" "$5" "$4}else{print $9"@"definition"@"$10" "$4" "$5}}'  > $base_name.coords
extract --nowrap $base_name.fna $base_name.coords | perl -pe 's/\ .*//g;s/\@/\ /g;' > $ffn_file
####In case of introns/frameshifts, get the correct sequence (full sequence)
for i in `cat $base_name.fs_intron_cds`
do
  protein_product=`grep -v "Parent=" $gff_file | grep -w "$i" | cut -f 9 | perl -pe "s/.*product\=//;s/\;.*//;s/ +/ /g;s/^\ //;s/\ /_/g;s/\,/_/g;s/\:/_/g;s/\;/_/g;s/\#/_/g;s/\'/_/g;s/\(/_/g;s/\)/_/g;s/\=/_/g;s/\//_/g;s/_+/_/g;s/_$//"`
  grep "Parent=" $gff_file | grep -w $i | awk 'BEGIN{FS="\t"}{if($7=="-"){print "dummy "$5" "$4}else{print "dummy "$4" "$5}}' > $base_name.fscoords
  echo ">$i $definition $protein_product" >> $base_name.ffn
  extract --nowrap $base_name.fna $base_name.fscoords | grep -v \> >> $base_name.ffn
  rm $base_name.fscoords
done
transeq $base_name.ffn fasta::stdout | perl -pe 's/_1\ /\ /;s/\*//g' > $base_name.faa
rm $base_name.coords $base_name.fs_intron_cds
exit 0
