#!/bin/bash

#hashbang line, tells the script it should use bash to interpret its content


# Script by CWF, adapted from github script and subg by Dominic Egger
# Last update: 04/15/2020
# this script is designed to create a .com file from given .xyz inputs for a transition state calculation  

# INSTRUCTIONS
#creat an alias in .bashrc or other bash profile
#call script using alias command and type filename, "alias reactant.xyz product.xyz guess.xyz"  for qst3 OR leave out guess.xyz if doing qst2
#type desired new filename without an extension (WILL OVERWRITE AN EXISTING .COM FILE IF SAME NAME IS USED)
#answer if qst2 or qst3, then change parameters if needed  

# Update History
# CWF 04/20/2020 original version
#============================================= Begin of script =================================================================================




# below function will grab info from starting file

inputr="$1" #declares the string with name of input file
reactant=${inputr%%.xyz} #cuts off the .com part of the input file and saves it to variable name for reactant

inputp="$2"
product=${inputp%%.xyz} #cuts off the .com part of the input file and saves it to variable name for reactant

inputg="$3"
guess=${inputg%%.xyz} #cuts off the .com part of the input file and saves it to variable name for reactant

function get_coordinates (){
	echo
	echo -e "\e[1;4mDesired unique filename? (without extension) \e[0m"
	read name #will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc

	if [ -z $name ]; #checks if anything was typed, note here the spaces between commands and brackets are necessary!
	then
	echo "must type something!"
	exit
	fi
	#echo $w_proc #sets answer if not blank
	
	echo
	echo -e "qst3 or qst2?"
	
}

function menu_type (){
# begins first menu function and shows options
echo
echo -e "\e[1;4mWhat should opt equal? (freq=noraman calc assumed)" 
echo -e "\e[0;36m[2] qst2,calcfc"
echo -e "\e[92m[3] qst3,calcfc"
echo -e "Press any other button to exit"

read answer
# reads number answer
case "$answer" in
# Note case command to start menu option designations
# Note variable is quoted.

  "2" | "2" )
      w_new="(qst2,calcfc)"
	#will set w_new variable to the answer choice, the other "1" is redundant, leftover from allowing capital or lowercase letters
	
  ;;
# Note double semicolon to terminate each option.

  "3" | "3" )
    w_new="(qst3,calcfc)"
	
	
  ;;
            * )
# Note termination of menu
# If no number is chosen, (blank or incorrect input) nothing happens to .com file
   
   echo -e "\e[31m Nevermind then."
   echo -e "\e[39m"
   exit
  ;;

esac
# Note termination of case command


# below function will ask for parameters
}

function get_par (){
	echo
	echo -e "\e[1;4mChoose your parameters!"
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
   
 	echo -e "\e[92mChange basis/functional? (default is m06/6-311g(d,p)) \e[0m"
	read w_fun

	if [ -z $w_fun ];
	then
	w_fun="m06/6-311g(d,p)"
	fi
	
	#echo $w_fun
 
 	echo -e "\e[92mChange solvent? (default is bromobenzene) \e[0m"
	read w_sol

	if [ -z $w_sol ];
	then
	w_sol="bromobenzene"
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
# opt=$w_new freq=noraman $w_fun scrf=(smd,solvent=$w_sol)
integral=grid=$w_grid temperature=$w_temp

$reactant

$charge $spin
EOL


tail -n +3 $inputr >> $name.com #grabs xyz minus first two lines
echo -e "" >> $name.com #must have empty line in .com file
}

function append_com (){
cat >> "$name"".com" << EOL
$product

$charge $spin
EOL
tail -n +3 $inputp >> $name.com #grabs xyz minus first two lines
echo -e "" >> $name.com #must have empty line in .com file

if [ -z $guess ];
	then
	echo -e "\n" >> $name.com #must have empty line in .com file
	else
cat >> "$name"".com" << EOL
$guess

$charge $spin
EOL
tail -n +3 $inputg >> $name.com #grabs xyz minus first two lines
echo -e "\n" >> $name.com #must have empty line in .com file
fi

}
# below function groups the above functions

function main (){
	get_coordinates
	menu_type
	get_par #ask for parameters
	write_com #generate com file
	append_com

}

main
#call main function

   
#!/bin/bash -l

#======================================= End of Script ======================================================================
