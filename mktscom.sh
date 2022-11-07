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
# CWF 03/15/2022 fixed issue where .com was incorrect formatting due to extra lines in .xyz files
#============================================= Begin of script =================================================================================




# below function will grab info from starting file

inputr="$1" #declares the string with name of input file
dos2unix "$1" > /dev/null 2>&1
reactant=${inputr%%.xyz} #cuts off the .com part of the input file and saves it to variable name for reactant

inputp="$2"
dos2unix "$2" > /dev/null 2>&1
product=${inputp%%.xyz} #cuts off the .com part of the input file and saves it to variable name for reactant

inputg="$3"
dos2unix "$3" > /dev/null 2>&1
guess=${inputg%%.xyz} #cuts off the .com part of the input file and saves it to variable name for reactant
SCRIPTPATH="$(dirname "$0")"

function update_variables(){
cd $SCRIPTPATH
context="script_variables.db"
if [ -f $context ]; then
 echo "loading current parameters..."
else
echo "creating script_variables.db to set default parameters..."
        cat > script_variables.db << EOL
Number of processors=
32
Memory=
80000MB
Functional=
m06
Basis=
6-311g(d,p)
Grid=
ultrafinegrid
Temperature=
298.15
Charge=
0
Spin=
1
Solvent(SMD)=
bromobenzene

# adding any extra lines above this one will break the script. Only edit the text below each respective field title!

EOL
fi

mapfile -t -O 1 var <$context
w_proc=${var[2]}
w_mem=${var[4]}
w_fun=${var[6]}
w_basis=${var[8]}
w_grid=${var[10]}
w_temp=${var[12]}
charge=${var[14]}
spin=${var[16]}
cd - > /dev/null
}

function menu1 (){
# asks user if they want to modify parameters other than optimization, if other answer is pressed assumes no
echo
echo -e "\e[0;33mThese are the currently set parameters:\e[0m" 
echo -e
echo -e "\e[0mProcessors =" 	$w_proc
echo "Memory =" 		$w_mem
echo "Functional =" 	$w_fun
echo "Basis =" 			$w_basis
echo "Grid =" 			$w_grid
echo "Temperature =" 	$w_temp
echo "Charge =" 		$charge
echo "Spin =" 			$spin
echo -e
echo -e "\e[92mSelect [Y, y, 1, or enter] to continue"
echo -e "\e[1;31mSelect [N, n, or 2] to exit"
echo -e "\e[35mSelect [3] to edit parameters (using nano), re-run script once your edits are complete \e[0m"

read answer

case "$answer" in
# Note variable is quoted.

  "Y" | "y" | "1" | "yes" |"Yes" )
  # Accept upper or lowercase input or 1.
 	#will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc
	
  ;;
  
    "N" | "n" | "2" | "no" |"No" |"NO" )
  # Accept upper or lowercase input or 1.
 	#will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc
	exit
  ;;
# Note double semicolon to terminate each option.

    "3" )
  # Accept upper or lowercase input or 1.
 	#will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc
	cd $SCRIPTPATH
	nano $context
	exit
  ;;
  
           * )
# If no number is chosen, (blank or incorrect input) nothing happens
   
esac

}

function menu2 (){
# asks user if they want to modify parameters other than optimization, if other answer is pressed assumes no
echo
echo -e "\e[0;36mDo you want to include a solvent?" 
echo -e "\e[\e[92m[Y or 1] yes"
echo -e "\e[1;31m[N or 2] no \e[0m"

read answer

case "$answer" in
# Note variable is quoted.

  "Y" | "y" | "1" | "yes" |"Yes" )
  # Accept upper or lowercase input or 1.
    echo "Type solvent or press enter for default solvent; currently set as: "${var[18]}
	#will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc
		read w_sol
		w_solcard="scrf=(smd,solvent="
		w_solend=")"
 
 if [ -z $w_sol ];
	then
	w_sol=${var[18]}
	fi

  ;;
# Note double semicolon to terminate each option.

  "N" | "n" | "2")
	echo -e "\e[39m"
	if [ -z $w_sol ];
	then
	w_sol=" "
	
	fi
  ;;
  
          * )
   # if other button is pressed	  
   # Empty input (hitting RETURN) fits here, too.
    
		w_solcard="scrf=(smd,solvent="
		w_solend=")"
		w_sol=${var[18]}
  ;;

esac

}
   
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
        
       
# below functions writes route card to com using prompt info from above
# Note that freq calculation is assumed!

function write_com (){
cat > "$name"".com" << EOL
%lindaworkers=in-cn1020
%nprocshared=$w_proc
%mem=$w_mem
%chk=$name.chk
# opt=$w_new freq=noraman $w_fun $w_basis $w_solcard$w_sol$w_solend
integral=grid=$w_grid temperature=$w_temp

$reactant

$charge $spin
EOL


tail -n +3 $inputr >> $name.temp1 #grabs xyz minus first two lines
sed '/^[[:space:]]*$/d' $name.temp1 > $name.temp2 #removes all blank lines
cat $name.temp2 >> $name.com # grabs coordinates and puts in .com
echo -e "" >> $name.com #adds single empty line
rm $name.temp1 ; rm $name.temp2 # removes temp files
}

function append_com (){
cat >> "$name"".com" << EOL
$product

$charge $spin
EOL
tail -n +3 $inputp >> $name.temp3 #grabs xyz minus first two lines
sed '/^[[:space:]]*$/d' $name.temp3 > $name.temp4 # removes all blank lines
cat $name.temp4 >> $name.com # grabs coordinates and puts in .com
echo -e "" >> $name.com #adds single empty line
rm $name.temp3 ; rm $name.temp4 #removes temp files

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
	update_variables
	menu1
	menu2
	get_coordinates
	menu_type
	write_com #generate com file
	append_com

}

main
#call main function

   
#!/bin/bash -l

#======================================= End of Script ======================================================================
