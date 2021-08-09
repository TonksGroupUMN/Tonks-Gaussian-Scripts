#!/bin/bash

#hashbang line, tells the script it should use bash to interpret its content


# Script by CWF, adapted from github script and subg by DTE
# Last update: 04/15/2020
# this script is designed to create a .com file from a given .xyz file 

# INSTRUCTIONS
#creat an alias in .bashrc or other bash profile
#call script using alias command and type filename, "alias filename.xyz"

# Update History
# CWF 04/14/2020 original version
# CWF 04/15/2020 reworked script due to previous incompatibility with multiple xyz files in same directory
#============================================= Begin of script =================================================================================



# below function will grab info from starting file

input="$1" #declares the string with name of input file
name=${input%%.xyz} #cuts off the .xyz part of the input file and saves it to variable name

# below function will ask for paramters

 function get_par (){
	echo
	echo -e "\e[1;4mChoose your parameters!"
#	echo -e "\e[0;92mChange nprocshared? (default is 32) \e[0m" #will submit question into terminal
#	read w_proc #will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc

#	if [ -z $w_proc ]; #checks if anything was typed, note here the spaces between commands and brackets are necessary!
#	then
#	w_proc=32 #sets default if blank
#	fi
#	#echo $w_proc #sets answer if not blank
#	echo -e "\e[92mChange mem? (default is 80000MB, include unit) \e[0m" #begin new question, repeat till done
#	read w_mem
#
#	if [ -z $w_mem ];
#	then
#	w_mem="80000MB"
#	fi
#	
#	#echo $w_mem
 #  
 #	echo -e "\e[92mChange functional? (default is M06L, use modcom or manually change calc type, set as calcfc,maxcyc=512 \e[0m"
#	read w_fun
#
#	if [ -z $w_fun ];
#	then
#	w_fun="M06L"
#	fi
 #
 #	echo -e "\e[92mChange basis? (default is def2TZVP, use modcom or manually change calc type, set as calcfc,maxcyc=512 \e[0m"
#	read w_basis

#	if [ -z $w_basis ];
#	then
#	w_basis="def2TZVP"
#	fi
	
	#echo $w_basis
 
#	echo -e "\e[92mChange grid? (default is ultrafinegrid) \e[0m"
#	read w_grid

#	if [ -z $w_grid ];
#	then
#	w_grid="ultrafinegrid"
#	fi
	
	#echo $w_grid
  
 #	echo -e "\e[92mChange temp? (default will be 298.15) \e[0m"
#	read w_temp

#	if [ -z $w_temp ];
#	then
#	w_temp="298.15"
#	
#	fi
#
#	#echo $w_temp

	echo -e "\e[92mChange charge? (default will be 0) \e[0m"
	read charge

	if [ -z $charge ];
	then
	charge="0"
	
	fi

	#echo $charge
#	
#		
#	echo -e "\e[92mChange spin? (default will be 1) \e[0m"
#	read spin
#
#	if [ -z $spin ];
#	then
#	spin="1"
#	
#	fi
#
#	#echo $spin
}
        
       
# below functions writes route card to com using prompt info from above
# Note that freq calculation is assumed!

function write_com (){
cat > "$name"".com" << EOL
%lindaworkers=in-cn1020
%nprocshared=32
%mem=80000MB
%chk=$name.chk
# opt=(calcfc,maxcyc=512) pm6

$name  

$charge 1
EOL
tail -n +3 $input >> $name.com #grabs xyz minus first two lines
echo -e "\n" >> $name.com #must have empty line in .com file
		



}

# below function groups the above functions

function main (){

	get_par #ask for parameters
	write_com #generate com file

}

main
#call main function

   
#!/bin/bash -l

#======================================= End of Script ======================================================================
