#!/bin/bash

main(){
	set_variables
	create_folders
	download_files
	create_log
#	make_unwritable
}
set_variables(){
	read -p "Enter the name of the strain separated by underscore e.g Coxiella_burnetti_RSA_331: " NAME
	read -p "paste the ftp address of the strain e.g ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/018/765/GCA_000018765.1_ASM1876v1: " FTP
	DATE=$(date +%Y-%m-%d)
	ROOT_FOLDER_NAME=$DATE-$NAME
	INPUT_FOLDER=$ROOT_FOLDER_NAME/input
	SOURCE=$FTP
}

create_folders(){
	mkdir -p $ROOT_FOLDER_NAME \
		$INPUT_FOLDER
}

download_files(){
	WGET_RESULT=`wget -q $SOURCE`
	if (( $? -ne 0 )); then
		rm -r $ROOT_FOLDER_NAME
		echo "\n"INVALID FTP \"$SOURCE\""\n"
		exit 1
	else
		wget -cP $INPUT_FOLDER \
			${SOURCE}/*fna.gz \
			${SOURCE}/*gff.gz
		gunzip $INPUT_FOLDER/*gz
		for FASTA in $(ls $INPUT_FOLDER | grep fna$)
		do
			mv $INPUT_FOLDER/$FASTA ${INPUT_FOLDER}/$(basename $FASTA .fna).fa
		done
	fi
}

create_log(){
	touch $ROOT_FOLDER_NAME/log.out
	echo "#" $DATE $SOURCE $(echo $NAME | sed "s/_/\ /g") \
     > $ROOT_FOLDER_NAME/log.out

}

make_unwritable(){
    chmod -R a-w $INPUT_FOLDER/ 
}
main

echo "\n"Downloaded \"$ROOT_FOLDER_NAME\""\n"

tree -a $ROOT_FOLDER_NAME

