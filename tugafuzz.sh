#!/bin/bash
# ./tugafuzz.sh <WORDLIST> <URL2FUZZ>


RESET='\033[00m'  
VERMELHO='\033[01;31m'
VERDE='\033[01;32m'
AZUL='\033[01;34m'
MAGENTA='\033[01;35m'
BRANCO='\033[01;37m'

DOMINIO=$(echo $2 | cut -d\/ -f3)
# Alterar para o directorio pretendido
DIRECTORIO='/home/username'

ffuf -c -w $1 -u $2/FUZZ -o $DIRECTORIO/$DOMINIO-res-pri.csv -of csv

# Remove O Cabecalho do CSV
sed -i '1d' $DIRECTORIO/$DOMINIO-res-pri.csv

# Loop o CSV para atribuir as cores as respostas HTTP
for x in `cat $DIRECTORIO/$DOMINIO-res-pri.csv`; do
	ESTECAMINHOWEB=$(echo $x | cut -d, -f1)
	ESTEESTADO=$(echo $x | cut -d, -f5)
	ESTETAMANHO=$(echo $x | cut -d, -f4)
	if [ `echo $ESTEESTADO | grep "^2"` ]; then echo -e $2"/"$ESTECAMINHOWEB" [Status: "${VERDE}$ESTEESTADO${RESET}", Size: "$ESTETAMANHO"]" >> $DIRECTORIO/$DOMINIO-res-final.txt.tmp; fi
	if [ `echo $ESTEESTADO | grep "^3"` ]; then echo -e $2"/"$ESTECAMINHOWEB" [Status: "${AZUL}$ESTEESTADO${RESET}", Size: "$ESTETAMANHO"]" >> $DIRECTORIO/$DOMINIO-res-final.txt.tmp; fi
	if [ `echo $ESTEESTADO | grep "^4"` ]; then echo -e $2"/"$ESTECAMINHOWEB" [Status: "${MAGENTA}$ESTEESTADO${RESET}", Size: "$ESTETAMANHO"]" >> $DIRECTORIO/$DOMINIO-res-final.txt.tmp; fi
	if [ `echo $ESTEESTADO | grep "^5"` ]; then echo -e $2"/"$ESTECAMINHOWEB" [Status: "${VERMELHO}$ESTEESTADO${RESET}", Size: "$ESTETAMANHO"]" >> $DIRECTORIO/$DOMINIO-res-final.txt.tmp; fi
done

# Resultado Ordenado
sort -t: -k3,3 $DIRECTORIO/$DOMINIO-res-final.txt.tmp > $DIRECTORIO/$DOMINIO-res-final.txt.tmp.ordenado

echo -e ${AZUL}"RESULTS: ${BRANCO}$2"${RESET} > $DIRECTORIO/$DOMINIO-res-final.txt
cat $DIRECTORIO/$DOMINIO-res-final.txt.tmp.ordenado >> $DIRECTORIO/$DOMINIO-res-final.txt 

cat $DIRECTORIO/$DOMINIO-res-final.txt
rm  $DIRECTORIO/$DOMINIO-{res-final.txt.tmp,res-final.txt.tmp.ordenado}
