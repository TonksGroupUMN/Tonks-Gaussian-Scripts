#!/bin/bash

#hashbang line, tells the script it should use bash to interpret its content


# Script by CWF, adapted from github script and subg by DTE
# Last update: 04/15/2020
# this script is designed to modify a given .com file 

# INSTRUCTIONS
#creat an alias in .bashrc or other bash profile
#call script using alias command and type filename, "alias filename.com"

# Update History
# CWF 04/15/2020 original version
#============================================= Begin of script =================================================================================



# below function will grab info from starting file

input="$1" #declares the string with name of input file
name=${input%%.com} #cuts off the .com part of the input file and saves it to variable name

# below function will use menu to choose desired opt command of .com, in fancy colors

function menu (){
# begins first menu function and shows options
echo
echo -e "\e[1;4mWhat should opt equal? (freq calc assumed)" 
echo -e "\e[0;36m[1] calcfc,maxcyc=512"
echo -e "\e[92m[2] ReadFc Geom=AllCheck Guess=Read (for regular)"
echo -e "\e[33m[3] TS,calcfc,maxcyc=512"
echo -e "\e[33m[4] TS,calcfc,noeigentest,maxcyc=512"
echo -e "\e[92m[5] ReadFc Geom=AllCheck Guess=Read (for TS)"
echo -e "\e[34m[6] restart"
echo -e "\e[35m[7] manual input \e[0m"
echo -e "\e[35m[8] manual input with no freq calc \e[0m"

echo -e "Press any other button to exit"

read answer
# reads number answer
case "$answer" in
# Note case command to start menu option designations
# Note variable is quoted.

  "1" | "1" )
      w_new="(calcfc,maxcyc=512)"
	w_f="freq"
	#will set w_new variable to the answer choice, the other "1" is redundant, leftover from allowing capital or lowercase letters
	
  ;;
# Note double semicolon to terminate each option.

  "2" | "2" )
    w_new="(ReadFc) Geom=AllCheck Guess=Read"
	w_f="freq"
	
  ;;
  
    "3" | "3" )
    w_new="(TS,calcfc,maxcyc=512)"
	w_f="freq=noraman"
	
  ;;
  
    "4" | "4" )
    w_new="(TS,calcfc,noeigentest,maxcyc=512)"
	w_f="freq=noraman"
	
  ;;

  "5" | "5" )
    w_new="(ReadFc) Geom=AllCheck Guess=Read"
	w_f="freq=noraman"
	
  ;;



    "6" | "6" )
    w_new="(restart)"
	w_f="freq"
	
  ;;

  
	"7" | "7" )
	echo "Please type your desired calculation (if blank returns to default)"
    read w_new
	w_f="freq"
# will read the manually typed answer, or set to default if left blank
	if [ -z $w_new ];
	then
	w_new="(calcfc,maxcyc=512)"
	w_f="freq"
	fi
	
	
  ;;
  
    "8" | "8" )
	echo "Please type your desired calculation (if blank returns to default)"
    read w_new
# will read the manually typed answer, or set to default if left blank
	if [ -z $w_new ];
	then
	w_new="(calcfc,maxcyc=512)"
	w_f=""
	fi
	sed -i '5 s/freq //' $name.com	
	
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
}


function menu2 (){
# asks user if they want to modify parameters other than optimization, if other answer is pressed assumes no
echo
echo -e "\e[1;4mModify other parameters) (other buttons default to no)" 
echo -e "\e[0;36m[Y or 1] yes (for freq or freq=noraman)"
echo -e "\e[92m[N or 2] no (freq option remains from input) \e[0m"

read answer

case "$answer" in
# Note variable is quoted.

  "Y" | "y" | "1" | "yes" |"Yes" )
  # Accept upper or lowercase input or 1.
    echo "Enter parameters"
	#will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc
	
  ;;
# Note double semicolon to terminate each option.

  "N" | "n" | "2")
	echo -e "\e[39m"
# sed command syntax is as follows: -i to omit output, " rather than ' to allow for variables to be used, 5 dictates 5th line is only edited
# begins edit after finding pattern match "opt=", stops edit after reaching blank space, replaces string after opt with variable, saves to .com
	sed -i "5 s%\(opt=\)[^[:space:]]\+%\1$w_new%g" $name.com
	exit		
	
  ;;
  
          * )
   # if other button is pressed	  
   # Empty input (hitting RETURN) fits here, too.
   
	echo -e "\e[39m"
	sed -i "5 s%\(opt=\)[^[:space:]]\+%\1$w_new%g" $name.com
	exit
  ;;

esac

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
# this function creates a temporary new .com file that will later replace the old. This was necessary so that xyz coordinates are not overwritten
function write_newcom (){
cat > "$name""new.com" << EOL
%lindaworkers=in-cn1020
%nprocshared=$w_proc
%mem=$w_mem
%chk=$name.chk
# opt=$w_new $w_f $w_fun scrf=(smd,solvent=$w_sol)
integral=grid=$w_grid temperature=$w_temp

$name 

$charge $spin
EOL

tail -n +11 $input >> $name""new.com #grabs xyz minus first two lines
echo -e "\n" >> $name""new.com #must have empty line in .com file

}

function overwrite (){
cp $name""new.com $name.com
rm $name""new.com
# this function is to replace old .com file with new .com and remove temporary .com


# below function groups the above functions

}
function main (){
	menu
	menu2
	get_par #ask for parameters
	write_newcom #generate com file
	overwrite
	

}

main
#call main function

   
#!/bin/bash -l

#======================================= End of Script ======================================================================
