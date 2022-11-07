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
	echo -e "\e[0;92mChange basis (default is def2-TZVP) \e[0m" #will submit question into terminal
	read w_basis #will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc

	if [ -z $w_basis ]; #checks if anything was typed, note here the spaces between commands and brackets are necessary!
	then
	w_basis=def2-TZVP #sets default if blank
	fi
	#echo $w_basis #sets answer if not blank
   
 	echo -e "\e[92mChange calculation? (default is df-rks) \e[0m"
	read w_calc

	if [ -z $w_calc1 ];
	then
	w_calc1="df-rks"
	fi
	
	#echo $w_calc1
	
	echo -e "\e[92mChange functional? (default is XC-m06)"
	read w_fun

	if [ -z $w_fun ];
	then
	w_fun="XC-m06"
	fi
	
	#echo $w_fun
	
	echo -e "\e[92mChange calc 1 options? (default is maxit=100,option2?, separate by commas) \e[0m"
	read w_calc1o

	if [ -z $w_calc1o ];
	then
	w_calc1o="maxit=100"
	fi
	
	#echo $w_calc1o
	
	
	echo -e "\e[92mChange calc 1 directives? (default is save, 2101.2) \e[0m"
	read w_calc1d

	if [ -z $w_calc1d ];
	then
	w_calc1d="save, 2101.2"
	fi
	
	#echo $w_calc1d
  
 	echo -e "\e[92mChange secondary calculation, options, and directives? (default is ibba,MAXIT_IB=999; orbital,2101.2; save,2103.2) \e[0m"
	read w_calc2

	if [ -z $w_calc2 ];
	then
	w_calc2="ibba,MAXIT_IB=999; orbital,2101.2; save,2103.2"
	
	fi

	#echo $w_calc2
	
	echo -e "\e[92mChange file handling directives? (default is orbital,2103.2; keepspherical; skipvirt) MUST MANUALLY CHANGE FILE HANDLING OPTIONS\e[0m"
	read w_save1

	if [ -z $w_save1 ];
	then
	w_save1="orbital,2103.2; keepspherical; skipvirt"
	
	fi

	#echo $w_save1
	
}
        
       
# below functions writes route card to com using prompt info from above
# Note that freq calculation is assumed!

function write_com (){
cat > "$name"".com" << EOL
memory,300,m;

geometry={
EOL
tail -n +3 $input >> $name.com #grabs xyz minus first two lines
cat >> "$name"".com" << EOL
}

basis=$w_basis
{$w_calc1,$w_fun,$w_calc1o; $w_calc1d}
{$w_calc2}
{put,xml,'$name.xml'; $w_save1}

EOL
# below function groups the above functions
}

function main (){

	get_par #ask for parameters
	write_com #generate com file

}

main
#call main function

   
#!/bin/bash -l

#======================================= End of Script ======================================================================
