#!/bin/bash
#echo "Please type the name of your organism"
#read org_name
#num_hits=`/usr/local/bioinformatics/bin/esearch -db sra -query "$org_name [orgn] AND transcriptome" | xmllint --xpath "ENTREZ_DIRECT/Count/text()" -`
num_hits=136
if [ "$num_hits" -eq 0 ]
then
  echo "No hits found"
  exit 0
else
  echo "$num_hits hits found"
  #sra_datablock=`/usr/local/bioinformatics/bin/esearch -db sra -query "$org_name [orgn] AND transcriptome" | /usr/local/bioinformatics/bin/efetch`
  sra_datablock=`cat $1`
  for hit in `seq 1 $num_hits`
  do
    hit_datablock=`echo "$sra_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE_SET/EXPERIMENT_PACKAGE[$hit]" -`
    sample_name=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/IDENTIFIERS/PRIMARY_ID/text()" -`
    sample_title=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/TITLE/text()" -`
    bioproject_accession=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/STUDY/IDENTIFIERS/EXTERNAL_ID[@namespace=\"BioProject\"]/text()" -`
    organism=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_NAME/SCIENTIFIC_NAME/text()" -`
    isolate=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"isolate\"]/VALUE/text()" -`
    cultivar=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"cultivar\"]/VALUE/text()" -`
    ecotype=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"ecotype\"]/VALUE/text()" -`
    age=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"age\"]/VALUE/text()" -`
    dev_stage=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"dev_stage\"]/VALUE/text()" -`
    geo_loc_name=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"geo_loc_name\"]/VALUE/text()" -`
    tissue=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"tissue\"]/VALUE/text()" -`
    biomaterial_provider=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"biomaterial_provider\"]/VALUE/text()" -`
    cell_line=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"cell_line\"]/VALUE/text()" -`
    cell_type=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"cell_type\"]/VALUE/text()" -`
    collected_by=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"collected_by\"]/VALUE/text()" -`
    collection_date=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"collection_date\"]/VALUE/text()" -`
    culture_collection=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"culture_collection\"]/VALUE/text()" -`
    disease=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"disease\"]/VALUE/text()" -`
    disease_stage=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"disease_stage\"]/VALUE/text()" -`
    genotype=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"genotype\"]/VALUE/text()" -`
    growth_protocol=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"growth_protocol\"]/VALUE/text()" -`
    height_or_length=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"height_or_length\"]/VALUE/text()" -`
    isolation_source=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"isolation_source\"]/VALUE/text()" -`
    lat_lon=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"lat_lon\"]/VALUE/text()" -`
    phenotype=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"phenotype\"]/VALUE/text()" -`
    population=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"population\"]/VALUE/text()" -`
    sample_type=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"sample_type\"]/VALUE/text()" -`
    sex=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"sex\"]/VALUE/text()" -`
    specimen_voucher=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"specimen_voucher\"]/VALUE/text()" -`
    temp=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"temp\"]/VALUE/text()" -`
    treatment=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"treatment\"]/VALUE/text()" -`
    description=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/SAMPLE/SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE[TAG=\"Description\"]/VALUE/text()" -`
#    bioproject_accession
#    sample_name
    library_ID=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/EXPERIMENT/DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_NAME/text()" -`
    title=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/EXPERIMENT/TITLE/text()" -`
    library_strategy=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/EXPERIMENT/DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_STRATEGY/text()" -`
    library_source=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/EXPERIMENT/DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_SOURCE/text()" -`
    library_selection=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/EXPERIMENT/DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_SELECTION/text()" -`
    library_layout=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/EXPERIMENT/DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_LAYOUT" - | perl -pe 's/\ .*//g;s/.*\<.*//g'`
    platform=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/EXPERIMENT/PLATFORM" - | perl -pe 's/\<PLATFORM\>\<//g;s/\>.*//'`
    instrument_model=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/EXPERIMENT/PLATFORM/$platform/INSTRUMENT_MODEL/text()" -`
    design_description=`echo "$hit_datablock" | xmllint --xpath "//EXPERIMENT_PACKAGE/EXPERIMENT/DESIGN/DESIGN_DESCRIPTION/text()" -`
    filetype=""
    filename=""
    filename2=""
    filename3=""
    filename4=""
    assembly=""
    fasta_file=""
    echo -e "$sample_name\t$sample_title\t$bioproject_accession\t$organism\t$isolate\t$cultivar\t$ecotype\t$age\t$dev_stage\t$geo_loc_name\t$tissue\t$biomaterial_provider\t$cell_line\t$cell_type\t$collected_by\t$collection_date\t$culture_collection\t$disease\t$disease_stage\t$genotype\t$growth_protocol\t$height_or_length\t$isolation_source\t$lat_lon\t$phenotype\t$population\t$sample_type\t$sex\t$specimen_voucher\t$temp\t$treatment\t$description\t$bioproject_accession\t$sample_name\t$library_ID\t$title\t$library_strategy\t$library_source\t$library_selection\t$library_layout\t$platform\t$instrument_model\t$design_description\t$filetype\t$filename\t$filename2\t$filename3\t$filename4\t$assembly\t$fasta_file"
#  done > "$org_name""_results.tsv"
  done > results.tsv
fi
