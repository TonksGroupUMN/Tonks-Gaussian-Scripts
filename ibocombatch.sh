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

w_basis=def2-TZVP #sets default if blank
w_calc1="df-rks"
w_fun="XC-m06"
w_calc1o="maxit=100"
w_calc1d="save, 2101.2"
w_calc2="ibba,MAXIT_IB=999; orbital,2101.2; save,2103.2"
w_save1="orbital,2103.2; keepspherical; skipvirt"
 
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

	write_com #generate com file

}

main
#call main function

   
#!/bin/bash -l

#======================================= End of Script ======================================================================
