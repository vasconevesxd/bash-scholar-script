#!/usr/bin/env bash

# =>DECLARE ARRAY
declare -a dataArray

# =>DEFINE CONSTANT
FILE="scholar_URLs.txt"
DIR="./Scholar"

#----------------------------------------------FUNCTIONS----------------------------------------------#
# =>FUNCTION TO EXTRACT AND DISPLAY THE INFO
showData()
{
	# => FILTER NECESSARY DATA FROM FILE
	name=$(cat $(echo "$DIR/${fileName}") | tr '<' '\n' | grep '"gsc_prf_in"' | tail -n3 | head -n1 | cut -d'>' -f2 | tr -d ' ')
	for i in $(seq 1 4)
	do
		dataArray[$i]=$(cat $(echo "$DIR/${fileName}") | tr '<' '\n' | grep 'gsc_rsb_std' | tail -n6 | head -n4 | cut -d'>' -f2 | tr '\n' ':' | cut -d':' -f$i)
	done
    
	# => DISPLAY DATA
	echo "----------------------------------------------------"
	echo "[A processar]: $url"
	if [ $1 -eq 0 ];then
		echo "[INFO] A utilizar o ficheiro local '$fileName'"
	fi
	echo "Scholar: '$name'"
	echo "Citacoes - Total: ${dataArray[1]}, ultimos 5 anos: ${dataArray[2]}"
	echo -e "H-Index - Total: ${dataArray[3]}, ultimos 5 anos: ${dataArray[4]}\n"
}

# =>FUNCTION TO SAVE ALL DATA ON THE RESPECTIVE FILES
saveData()
{
	if [  ! -f $(echo "$DIR/$name.db") ];then # =>VERIFY IF FILE EXIST

		# =>CREATE "FILENAME.db" IF NOT EXIST AND SAVE THE DATA
		echo "# Ficheiro: '$name.db'" > $(echo "$DIR/$name.db")
		echo "# Info Scholar: '$name'" >> $(echo "$DIR/$name.db")
		echo "# Criado em: $(date +%Y.%m.%d_%Hh%M:%S)" >> $(echo "$DIR/$name.db")
		echo "Citacoes:Citacoes-5anos:h-index:h-index_5anos" >> $(echo "$DIR/$name.db")

	else
		# =>IF "FILENAME.db" EXIST, KEEP OLD $countLines FIRST LINES
		let "countLines = $(cat $(echo "$DIR/$name.db") | wc -l)-1"
		echo "$(cat $(echo "$DIR/$name.db") | head -n$countLines)" > $(echo "$DIR/$name.db")
	fi
	# =>SAVE THE UPDATED VALUES AND TODAYS DATE
	echo "$(date +%Y.%m.%d):${dataArray[1]}:${dataArray[2]}:${dataArray[3]}:${dataArray[4]}" >> $(echo "$DIR/$name.db")
	echo "# Ultima atualizacao: $(date +%Y.%m.%d_%Hh%M:%S)" >> $(echo "$DIR/$name.db")
}

# =>CHECK IF $FILENAME EXIST
checkFile()
{
	if [ ! -f $(echo "$DIR/$fileName") ]; then
		echo -e "[ERRO] Não foi possível encontrar o ficheiro ‘$fileName’\n"
		exit 2
	fi
}

# =>UPDATE OR SET FILENAME AND URL
getData()
{
	url=$(cat $FILE | grep -v '^#' | tr '\n' ';' | cut -d';' -f${i} | cut -d'|' -f1)
	fileName=$(cat $FILE | grep -v '^#' | tr '\n' ';' | cut -d';' -f${i} | cut -d'|' -f2)
}

# =>DISPLAY LOCAL DATA IN THE LIST $FILE 
localURLs()
{
	for i in $(seq 1 $totalLines)
	do
		getData
		checkFile
		
		# =>IF $FILENAME EXIST DISPLAY DATA OF $FILENAME
		showData $1
	done
}

getURLs()
{
	for i in $(seq 1 $totalLines)
	do
		getData
		
		# =>SAVE HTML FILE AS FILENAME ON THE SUBDIRECTORY
		wget -qO $(echo "$DIR/$fileName") $url
        
		# =>CALL FUNCTIONS
		checkFile
		showData $1
		saveData
	done
}

#----------------------------------------------MAIN SCRIPT----------------------------------------------#

# =>CHECK IF FILE EXIST ON THE CURRENT DIRECTORY
if [ ! -f $FILE ]; then
	echo "[ERRO] Não foi possivel encontrar ‘$FILE’"
	exit 1
fi

# =>COUNT THE URLs AVAILABLE ON $FILE 
totalLines=$(cat $FILE | grep -v '^#' | wc -l)

# =>IF PARAMETER EQUAL TO "-i"
if [ "$1" = "-i" ]; then
	# =>CREATE SUBDIRECTORY "Scholar" IF NOT EXIST
	mkdir -p $(echo "$DIR" | cut -d'/' -f2)
	# =>CALL FUNCTION getURLs
	getURLs $#
	exit 0
fi

# =>IF PARAMETER EQUAL TO "-h"
if [ "$1" = "-h" ]; then
	# =>DISPLAY HELP OPTION
	echo "google_scholar: ./google_scholar.sh [OPCOES]"
	echo -e "  Mostra as informacoes dos ficheiros HTML que estao no subdiretorio e que estao na lista.\n"
	echo "  Opcoes:"
	echo "      -i      Transferir os ficheiros HTML dos respetivos URLs que estao na lista"
	echo -e "      -h      Mostra informacoes sobre o script e opcoes\n"
	exit 0
fi
        
# =>IF NO PARAMETERS
if [ $# -eq 0 ]; then # => $# - PARAMETERS COUNTER
	# =>DISPLAY INFO OF ALL ON THE LIST $FILE
	localURLs $#
	exit 0
fi

# =>DO IF PARAMETER NOT VALID
echo "[SYNTAX ERRO]: ./google_scholar.sh [OPCOES]"
echo -e "Exemplo: ./google_scholar.sh -i\n"
