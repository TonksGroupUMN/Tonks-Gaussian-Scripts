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
input="$1" #declares the string with name of input file
dos2unix "$1" > /dev/null 2>&1 # converts any dos files to unix
name=${input%%.com} #cuts off the .xyz part of the input file and saves it to variable name
SCRIPTPATH="$(dirname "$0")" # determines the script's path is the appropriate directory

# below function will ask for paramters

function update_variables(){ # creates variables file if it doesn't exit
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

mapfile -t -O 1 var <$context # stores variables for route card
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

# below function will use menu to choose desired opt command of .com, in fancy colors

function menu (){ # begins first menu function and shows options
echo
echo -e "\e[1;4mWhat should opt equal? (freq calc assumed)" 
echo -e "\e[0;36m[1] calcfc,maxcycle=512"
echo -e "\e[36m[2] ReadFc Geom=AllCheck Guess=Read (for GS)"
echo -e "\e[36m[3] calcfc,maxcyc=512 + NMR=GIAO"
echo -e "\e[33m[4] TS,calcfc,maxcycle=512"
echo -e "\e[33m[5] TS,calcfc,noeigentest,maxcyc=512"
echo -e "\e[33m[6] ReadFc Geom=AllCheck Guess=Read (for TS)"
echo -e "\e[92m[7] restart"
echo -e "\e[35m[8] manual input \e[0m"
echo -e "\e[35m[9] manual input with no freq calc \e[0m"

echo -e "Press any other button to exit"

read answer
case "$answer" in
# Note case command to start menu option designations
# Note variable is quoted.

  "1" | "1" )
    w_new="(calcfc,maxcycle=512)"
	w_f="freq"
	#will set w_new variable to the answer choice, the other "1" is redundant, leftover from allowing capital or lowercase letters
	
  ;;
# Note double semicolon to terminate each option.

  "2" | "2" )
    w_new="(ReadFc) Geom=AllCheck Guess=Read"
	w_f="freq"
	
  ;;
  
  "3" | "3" )
    w_new="(calcfc,maxcycle=512)"
	w_f="freq"
	w_miscoption="NMR=GIAO"
	
  ;;  
  
    "4" | "4" )
    w_new="(TS,calcfc,maxcycle=512)"
	w_f="freq=noraman"
	
  ;;
  
  "5" | "5" )
    w_new="(TS,calcfc,noeigentest,maxcycle=512)"
	w_f="freq=noraman"
	
  ;;

  "6" | "6" )
    w_new="(ReadFc) Geom=AllCheck Guess=Read"
	w_f="freq=noraman"
	
  ;;

  "7" | "7" )
    w_new="(restart)"
	w_f="freq"
	
  ;;
  
  "8" | "8" )
	echo "Please type your desired calculation (if blank returns to default)"
    read w_new
	w_f="freq"
# will read the manually typed answer, or set to default if left blank
	if [ -z $w_new ];
	then
	w_new="(calcfc,maxcycle=512)"
	w_f="freq"
	fi
	
  ;;
  
    "9" | "9" )
	echo "Please type your desired calculation (if blank returns to default)"
    read w_new
# will read the manually typed answer, or set to default if left blank
	if [ -z $w_new ];
	then
	w_new="(calcfc,maxcycle=512)"
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

function get_par (){
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
echo "Solvent (if applicable) = ${var[18]}"
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
  
esac

}

function get_sol (){
# asks user if they want to include a solvent, presumed yes if no answer given
echo
echo -e "\e[0;36mDo you want to include a solvent? currently set as: ${var[18]}" 
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
        
# below functions writes route card to com using prompt info from above
# Note that freq calculation is assumed! 
# this function creates a temporary new .com file that will later replace the old. This was necessary so that xyz coordinates are not overwritten
function write_newcom (){
cat > "$name""new.com" << EOL
%lindaworkers=in-cn1020
%nprocshared=$w_proc
%mem=$w_mem
%chk=$name.chk
# opt=$w_new $w_f $w_fun/$w_basis $w_solcard$w_sol$w_solend
integral=grid=$w_grid temperature=$w_temp $w_miscoption
placeholderline
$name  
placeholderline
$charge $spin
EOL

sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba' $input >> $name""new1.com
awk -v RS='\n\n' 'END{printf "%s",$0}' $name""new1.com > $name""new2.com
tail -n +2 $name""new2.com >> $name""new.com
# tail -n +11 $input >> $name""new.com #grabs xyz minus first two lines
echo "" >> $name""new.com;  sed -i '/^$/d;$G' $name""new.com; sed -i '/^$/d;$G' $name""new.com #^$ means match a line that has nothing between the beginning and the end (blank line) "The "d" command deletes an entire line that contains a matching pattern"
sed -i 's/placeholderline//' $name""new.com
# echo -e "\n" >> $name""new.com #must have empty line in .com file

}

function overwrite (){
cp $name""new.com $name.com
rm $name""new.com
rm $name""new1.com
rm $name""new2.com
# this function is to replace old .com file with new .com and remove temporary .com


# below function groups the above functions

}
function main (){
	update_variables
	menu
	get_par #ask for parameters
	get_sol # ask if solvent is needed
	write_newcom #generate com file
	overwrite
	

}

main
#call main function

   
#!/bin/bash -l

#======================================= End of Script ======================================================================
