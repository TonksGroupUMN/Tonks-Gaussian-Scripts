#!/bin/bash

#hashbang line, tells the script it should use bash to interpret its content


# Script by CWF, adapted from github script and subg by DTE
# Last update: 04/15/2020
# this script is designed to create a .com file from a given .xyz file 

# INSTRUCTIONS
#creat an alias in .bashrc or other bash profile
#call script using alias command and type filename, "alias filename.xyz"
#to change the defaults, open script and change instances of old default to new desired default

# Update History
# CWF 04/14/2020 original version
# CWF 04/15/2020 reworked script due to previous incompatibility with multiple xyz files in same directory
# CWF this one is for pseudo potentials
#============================================= Begin of script =================================================================================



# below function will grab info from starting file

input="$1" #declares the string with name of input file
name=${input%%.xyz} #cuts off the .xyz part of the input file and saves it to variable name

# below function will ask for paramters

function menu1 (){
# asks user if they want to freq 
echo
echo -e "Frequency calculation?" 
echo -e "\e[0;36m[Y or 1] yes (for freq)"
echo -e "\e[92m[N or 2] no (for no freq) \e[0m"

read answer

case "$answer" in
# Note variable is quoted.

  "Y" | "y" | "1" | "yes" |"Yes" )
  # Accept upper or lowercase input or 1.
	#will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc
	w_fr="freq"
  ;;
# Note double semicolon to terminate each option.

  "N" | "n" | "2")
	echo -e "\e[39m"
	
  ;;
  
          * )
		  
		    ;;

esac
 }
 
function menu2 (){ 
# asks user if they want to pseudo 
echo
echo -e "Pseudo?" 
echo -e "\e[0;36m[Y or 1] yes (for pseudo=read)"
echo -e "\e[92m[N or 2] no (for no pseudo) \e[0m"

read answer

case "$answer" in
# Note variable is quoted.

  "Y" | "y" | "1" | "yes" |"Yes" )
  # Accept upper or lowercase input or 1.
	#will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc
	w_pseudo="pseudo=read"
	echo -e "\e[0;92mRegular atoms for 1st functional and charge? Separate with single space (default is H C P O 0), MUST ADD CHARGE \e[0m" #will submit question into terminal
	read w_normalatoms #will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc

	if [ -z "$w_normalatoms" ]; #checks if anything was typed, note here the spaces between commands and brackets are necessary!
	then
	w_normalatoms="H C P O 0"
	fi
	
	echo -e "\e[0;92mFunctional for regular atoms? (default is 6-31G(d,p)) \e[0m" #will submit question into terminal
	read w_normalatomsfun #will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc

	if [ -z "$w_normalatomsfun" ]; #checks if anything was typed, note here the spaces between commands and brackets are necessary!
	then
	w_normalatomsfun="6-31G(d,p)" #sets default if blank
	fi

	echo -e "\e[92mHeavy atoms for 2nd functional and charge? (by default Pd 0) \e[0m" #begin new question, repeat till done
	read w_heavyatoms

	if [ -z "$w_heavyatoms" ];
	then
	w_heavyatoms="Pd 0"
	fi
	echo -e "\e[92mHeavy atoms functional? (by default SDD) \e[0m" #begin new question, repeat till done
	read w_heavyatomsfun

	if [ -z "$w_heavyatomsfun" ];
	then
	w_heavyatomsfun="SDD"
	fi
  ;;
# Note double semicolon to terminate each option.

  "N" | "n" | "2")
	echo -e "\e[39m"

 ;;
  
  
        * )
		
				    ;;

esac
 }

function get_par (){
	echo
	echo -e "\e[1;4mChoose your parameters! (press enter for default)"
	echo -e "\e[0;92mChange nprocshared? (default is 32) \e[0m" #will submit question into terminal
	read w_proc #will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc

	if [ -z $w_proc ]; #checks if anything was typed, note here the spaces between commands and brackets are necessary!
	then
	w_proc=32 #sets default if blank
	fi
	#echo $w_proc #sets answer if not blank
	echo -e "\e[92mChange mem? (default is 80000MB, include unit) \e[0m" #begin new question, repeat till done
	read w_mem

	if [ -z $w_mem ];
	then
	w_mem="80000MB"
	fi
	
	#echo $w_mem
   
 	echo -e "\e[92mChange basis/functional? (default is m06/gen, calc type always set as calcfc,maxcyc=512 \e[0m"
	read w_fun

	if [ -z $w_fun ];
	then
	w_fun="m06/gen"
	fi
	
	#echo $w_fun
 
 	echo -e "\e[92mChange solvent? (default is toluene) \e[0m"
	read w_sol

	if [ -z $w_sol ];
	then
	w_sol="toluene"
	fi
	
	#echo $w_sol
 
	echo -e "\e[92mChange grid? (default is ultrafinegrid) \e[0m"
	read w_grid

	if [ -z $w_grid ];
	then
	w_grid="ultrafinegrid"
	fi
	
	#echo $w_grid
  
 	echo -e "\e[92mChange temp? (default will be 296.15) \e[0m"
	read w_temp

	if [ -z $w_temp ];
	then
	w_temp="296.15"
	
	fi

	#echo $w_temp

	echo -e "\e[92mChange charge? (default will be 0) \e[0m"
	read charge

	if [ -z $charge ];
	then
	charge="0"
	
	fi

	#echo $charge
	
		
	echo -e "\e[92mChange spin? (default will be 1) \e[0m"
	read spin

	if [ -z $spin ];
	then
	spin="1"
	
	fi

	#echo $spin
}
        
       
# below functions writes route card to com using prompt info from above
# Note that freq calculation is assumed!

function write_com (){
cat > "$name"".com" << EOL
%lindaworkers=in-cn1020
%nprocshared=$w_proc
%mem=$w_mem
%chk=$name.chk
# opt=(calcfc,maxcyc=512) $w_fr $w_fun $w_pseudo scrf=(smd,solvent=$w_sol)
integral=grid=$w_grid temperature=$w_temp

$name  

$charge $spin
EOL
tail -n +3 $input >> $name.com #grabs xyz minus first two lines
echo -e "" >> $name.com #must have empty line in .com file
cat >> "$name"".com" << EOL
$w_normalatoms
$w_normalatomsfun
****
$w_heavyatoms
$w_heavyatomsfun
****

$w_heavyatoms
$w_heavyatomsfun
EOL
echo -e "\n" >> $name.com #must have empty line in .com file


}

# below function groups the above functions

function main (){
	menu1
	menu2
	get_par #ask for parameters
	write_com #generate com file

}

main
#call main function

   
#!/bin/bash -l

#======================================= End of Script ======================================================================
