#!/bin/bash

#########################################################################
#                              getxyz	                                
# Made by:  Leonardo Israel Lugo Fuentes (LeoLugoF)   			
# 								
# Date:     21/Junary/2020                                              
#                                                                       
# This program reads gaussian output files				
# It searches the last XYZ coordinates found from the output		                                                                       
# Command line (i.e): bash getxyz.sh [*.log/*.out]                      
# Example  :    bash getxyz.sh water.out 
# 04/14/2020 Modified by CWF to change how termination check works, full credit to LeoLugoF
#########################################################################

declare -A ptable
#ptable['key']='value'
ptable=( ["1"]="H" ["2"]="He" ["3"]="Li" ["4"]="Be" ["5"]="B" ["6"]="C" ["7"]="N" ["8"]="O" 
 ["9"]="F" ["10"]="Ne" ["11"]="Na" ["12"]="Mg" ["13"]="Al" ["14"]="Si" ["15"]="P" ["16"]="S" 
  ["17"]="Cl" ["18"]="Ar" ["19"]="K" ["20"]="Ca" ["21"]="Sc" ["22"]="Ti" ["23"]="V" ["24"]="Cr"
   ["25"]="Mn" ["26"]="Fe" ["27"]="Co" ["28"]="Ni" ["29"]="Cu" ["30"]="Zn" ["31"]="Ga" ["32"]="Ge"
    ["33"]="As" ["34"]="Se" ["35"]="Br" ["36"]="Kr" ["37"]="Rb" ["38"]="Sr" ["39"]="Y" ["40"]="Zr"
     ["41"]="Nb" ["42"]="Mo" ["43"]="Tc" ["44"]="Ru" ["45"]="Rh" ["46"]="Pd" ["47"]="Ag" ["48"]="Cd"
      ["49"]="In" ["50"]="Sn" ["51"]="Sb" ["52"]="Te" ["53"]="I" ["54"]="Xe" ["55"]="Cs" ["56"]="Ba" 
       ["71"]="Lu" ["72"]="Hf" ["73"]="Ta" ["74"]="W" ["75"]="Re" ["76"]="Os" ["77"]="Ir" ["78"]="Pt"
        ["79"]="Au" ["80"]="Hg" ["81"]="Tl" ["82"]="Pb" ["83"]="Bi" ["84"]="Po" ["85"]="At" ["86"]="Rn" )

if [ -z "$1" ];
then
	echo "Insert the name of the gaussian output after the name of the script."
	echo "This script extracts the last xyz coordinates from a gaussian output"
else

	awk -F " " 'NF==6' $1 | tac | awk '/Rotational/{p=1} p; /Number/{exit}' | tac | awk '/Number/{p=1} p; /Rotational/{exit}' | tail -n +2 | tac | tail -n +2 | tac | awk '{print $2 " " $4 " " $5 " " $6}' > "${1%%.*}1.xyz"
	NAtoms=$(awk -F " " 'NF==6' $1 | tac | awk '/Rotational/{p=1} p; /Number/{exit}' | tac | awk '/Number/{p=1} p; /Rotational/{exit}' | tail -n +2 | tac | tail -n +2 | tac | tail -1 | awk '{print $1}')


	if [ "$(wc -w ${1%%.*}1.xyz)" == 0 ];
	then
		echo "No coordinates found"
		rm "${1%%.*}1.xyz"
	else
		echo "$NAtoms" > "${1%%.*}.xyz"
		echo "${1%%.*}" >> "${1%%.*}.xyz"
		while IFS= read -r line
		do
			an=$(echo "$line" | awk '{print $1}') 
			as="${ptable[$an]}"
			Info=$(echo "$line" | awk '{print $1=as " " $2 " " $3 " " $4}' as="$as")
			echo $Info >> "${1%%.*}.xyz"
			sed -i 's/ -/\t-/g' "${1%%.*}.xyz"
		done < "${1%%.*}1.xyz"
		rm "${1%%.*}1.xyz"
		sed -i 's/ /\t /g' "${1%%.*}.xyz"  
		finaline=$(tail -1 $1)
		echo "Quick check if Gaussian terminated normally or if potentially an error occured:"
    grep "Normal termination" $1
    echo 
 
echo
	fi
fi
