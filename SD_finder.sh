#!/bin/bash
bait_sequence=$1
fe_cutoff=$2
gene_list_file=$3
a=0
if [ ! -f RNA_duplex_table ]
then
  for i in a c g t
  do
    for j in a c g t
    do
      for k in a c g t
      do
        for l in a c g t
        do
          for m in a c g t
          do
            for n in a c g t
            do
              let a=a+1
              echo "Calculating free energy for duplex $a"
              free_energy=`echo -e "$i$j$k$l$m$n\n$bait_sequence" | RNAduplex | cut -d\: -f2 | cut -d\( -f2 |cut -d\) -f1`
              echo -e "Sequence_$a\t$i$j$k$l$m$n\t$free_energy" >> RNA_duplex_table
            done
          done
        done
      done
    done
  done
fi
min_fe_val=`cat RNA_duplex_table | awk '{print $3}' | sort -n | uniq | head -n1`
echo "`cat RNA_duplex_table | awk -v min_fe="$min_fe_val" -v fe_cutoff="$fe_cutoff" '{if($3<( min_fe * fe_cutoff)){print $AF}}'`" > RNA_duplex_table
cat RNA_duplex_table | awk '{print $2}' > id_seqs
echo -e "SD-like sequence\tPosition\tFree energy (for interaction with sequence $bait_sequence)" > SD_like_sequences
echo "##############################" >> SD_like_sequences
for o in `cat $gene_list_file | grep \> | awk '{print $1}' | perl -pe 's/\>//'`
do
  data_block=`seqret $gene_list_file:$o raw::stdout | perl -pe 's/\n//' | grep -i -o -b -f id_seqs`
  if [ ! -z "$data_block" ]
  then
    echo $o >> SD_like_sequences
    for p in $data_block
    do
      sd_like_sequence=`echo $p | cut -d\: -f2`
      sd_position=`echo $p | cut -d\: -f1 | awk '{print $1+1}'`
      free_energy=`grep -iw $sd_like_sequence RNA_duplex_table | awk '{print $3}'`
      echo -e "$sd_like_sequence\t$sd_position\t$free_energy" >> SD_like_sequences
    done
    echo "##############################" >> SD_like_sequences
  fi
done
