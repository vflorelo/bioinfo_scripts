#!/bin/bash
###Definicion de variables, aqui el script tiene la instruccion de buscar en el archivo PFPR_tab.txt
tab_file="PFPR_tab.txt"
###Definicion de variables, aqui el script quita la cabecera de la tabla y las lineas vacias
tab_data_block=`cat "$tab_file" | tail -n+2 | grep -v ^$`
###Definicion de variables, aqui el script ubica el numero de acceso a partir del PFPR_tab.txt
accession=`echo "$tab_data_block" | cut -f1 | sort | uniq | grep -v ^$`
###Definicion de variables, aqui el script determina hasta donde llega el encabezado del genbank, es decir, no secuencias, no proteinas, solo informacion del genoma
feat_line=`cat $accession.gbk | grep -n -w FEATURES | cut -d\: -f1`
###Definicion de variables, el encabezado del genbank
gbk_header=`cat $accession.gbk | head -n $feat_line | perl -pe 's/^/\@/g;s/\n//g;s/\@\ \ \ \ \ \ \ \ \ \ \ \ /\t/g;s/\@/\n/g'`
###Definicion de variables, el nombre del organismo
organism_name=`grep -w -m1 SOURCE $accession.gbk | perl -pe 's/^SOURCE\ \ \ \ \ \ //; s/\.//g; s/\=//g; s/\*//g; s/\ /_/g;' | tr -s '_'`
###Prueba para determinar si el archivo a procesar corresponde a la secuencia del plasmido
plasmid=`echo "$gbk_header" | grep DEFINITION | grep -i plasmid`
if [ -z "$plasmid" ]
then
  source_name="$organism_name"
else
  source_name=`echo "$gbk_header" | grep DEFINITION | cut -d\, -f1 | perl -pe 's/^DEFINITION\ \ //; s/\.//g; s/\=//g; s/\*//g; s/\ /_/g;' | tr -s '_'`
fi	
###Control, numero de fagos encontrados
total_phages=`echo "$tab_data_block" | wc -l`
###Procesamiento de la tabla, el genoma de la bacteria y generacion de archivos
###El siguiente bloque se lee como:
### for i in `seq 1 $total_phages` -> "Por cada elemento en la lista del 1 al total de fagos" (por si hay uno, dos, diezmil) haz lo siguiente (do)
for i in `seq 1 $total_phages`
do
  ###Definicion de variables, la linea completa correspondiente al profago "i"
  line_data_block=`echo "$tab_data_block" | tail -n+$i | head -n1`
  ###Definicion de variables, donde empieza (phage_start) y donde termina (phage_end) el profago
  phage_start=`echo $line_data_block | awk '{if($4>$5){print $5}else{print $4}}'`
  phage_end=`echo $line_data_block | awk '{if($4>$5){print $4}else{print $5}}'`
  ###Procesamiento, seqret extrae la secuencia y anotaciones correspondientes unicamente al profago
  seqret -feature $accession.gbk -sbegin $phage_start -send $phage_end gff3::stdout | grep -w CDS > $source_name.prophage.$i.gff
  seqret $accession.gbk -sbegin $phage_start -send $phage_end fasta::stdout | perl -pe "s/\>.*/\>$organism_name\.prophage.$i/" > $source_name.prophage.$i.fna
  ###Procesamiento, build_gen_map... bueno, es bastante claro lo que hace
  build_gen_map $source_name.prophage.$i single
  ###Definicion de variables, cuantas proteinas hay en el profago "i"
  total_CDS=`cat $source_name.prophage.$i.gff | wc -l`
  ###Procesamiento de la lista de regiones codificantes
  ###El siguiente bloque se lee como:
  ### for j in `seq 1 $total_CDS` -> "Por cada elemento en la lista del 1 al total de CDS" (por si hay una, dos, diezmil) haz lo siguiente (do)
  for j in `seq 1 $total_CDS`  
  do
    ###Definicion de variables, todas las propiedades del CDS "j", inicio, termino, cadena, producto, inferencia... you name it
    data_block=`cat $source_name.prophage.$i.gff | tail -n+$j | head -n1`
    five_prime=`echo "$data_block" | cut -f4`
    three_prime=`echo "$data_block" | cut -f5`
    strand=`echo "$data_block" | cut -f7`
    product=`echo "$data_block" | cut -f9 | perl -pe 's/\;/\n/g' | grep product | cut -d\= -f2 | perl -pe 's/\"//g;s/\ /_/g'`
    locus_tag=`echo "$data_block" | cut -f9 | perl -pe 's/\;/\n/g' | grep locus_tag | cut -d\= -f2 | perl -pe 's/\"//g'`
    CDS_id=`echo "$data_block" | cut -f9 | perl -pe 's/\;/\n/g' | grep ID\= | cut -d\= -f2 | perl -pe 's/\"//g'`
    ###Definicion de variables, lo que va a ir en el fasta de esa region
    fasta_header=$CDS_id@$source_name@$product
    ###Procesamiento, aqui se construye un archivo de coordenadas para sacar los genes y poderlos traducir a proteinas
    echo $five_prime $three_prime $strand $fasta_header | awk '{if($3=="-"){print $4,$2,$1}else{print $4,$1,$2}}'  >> $source_name.prophage.$i.coords
    ###Limpieza de variables, por si las flies
	unset data_block five_prime three_prime strand product locus_tag CDS_id fasta_header
  done
  ###Procesamiento, aqui se obtiene el multifasta de los genes a partir del archivo de coordenadas
  extract --nowrap $source_name.prophage.$i.fna $source_name.prophage.$i.coords | perl -pe 's/\ .*//g;s/\@/\ /g' > $source_name.prophage.$i.ffn
  ###Procesamiento, aqui se traduce el archivo multifasta de los genes, se eliminan caracteres no validos
  transeq $source_name.prophage.$i.ffn fasta::stdout | perl -pe 's/_1\ /\ /;s/\*//g' > $source_name.prophage.$i.faa
  ###Termina y repite con el siguiente profago
done
exit 0
