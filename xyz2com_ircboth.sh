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
# CWF 03/15/2022 adding parsing for extension, errors if incorrect
#============================================= Begin of script =================================================================================

# below function will grab info from starting file

input="$1" #declares the string with name of input file
dos2unix "$1" > /dev/null 2>&1
name=${input%%.xyz} #cuts off the .xyz part of the input file and saves it to variable name
extension="${input##*.}"
case "$input" in
*.xyz ) 
        # correct format
        ;;
*)
        echo -e "\e[35mInput file is incorrect format, please use *.xyz \e[0m"
		exit
        ;;
esac
SCRIPTPATH="$(dirname "$0")"

# below function will ask for paramters

function update_variables(){
cd $SCRIPTPATH
context="script_variables_irc.db"
if [ -f $context ]; then
 echo "loading current parameters..."
else
echo "creating script_variables_irc.db to set default parameters..."
        cat > script_variables_irc.db << EOL
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
Step Size for IRC
5
MaxPoints for IRC
100

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
steps=${var[20]}
points=${var[22]}
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
echo "Solvent (if applicable) = ${var[18]}"
echo -e
echo -e "\e[92mSelect [Y, y, 1, or enter] to continue"
echo -e "\e[1;31mSelect [N, n, or 2] to exit"
echo -e "\e[35mSelect [3] to edit parameters (using nano), re-run script once your edits are complete \e[0m"
echo -e "\e[36mSelect [4] to create input for a pm6 calculation instead\e[0m"

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
  
   "4" )
  # Accept upper or lowercase input or 1.
 	#will read user answer, w_proc is the string that is needed when writing .com, call back to with $w_proc
	cat > "$name"".com" << EOL
%lindaworkers=in-cn1020
%nprocshared=32
%mem=80000MB
%chk=$name.chk
# opt=(calcfc,maxcycle=512) pm6
print

$name  

$charge 1
EOL
	tail -n +3 $input >> $name.com #grabs xyz minus first two lines
	echo -e "\n" >> $name.com #must have empty line in .com file
	exit
  ;;
  
  
          * )
# If no number is chosen, (blank or incorrect input) nothing happens
   
esac

}

     
function menu2 (){
# asks user if they want to modify parameters other than optimization, if other answer is pressed assumes no
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

function write_com_forward (){
cat > "$name""_forward.com" << EOL
%lindaworkers=in-cn1020
%nprocshared=$w_proc
%mem=$w_mem
%chk=$name.chk
# irc=(calcfc,forward,maxpoints=$points,stepsize=$steps) $w_fun/$w_basis $w_solcard$w_sol$w_solend scf=(xqc,maxconventionalcycle=20,tight,IntRep)
integral=grid=$w_grid temperature=$w_temp

$name  

$charge $spin
EOL
tail -n +3 $input >> $name""_forward.com #grabs xyz minus first two lines
echo -e "\n" >> $name""_forward.com #must have empty line in .com file
		
mkdir forward
mv "$name""_forward.com" forward/


}

function write_com_reverse (){
cat > "$name""_reverse.com" << EOL
%lindaworkers=in-cn1020
%nprocshared=$w_proc
%mem=$w_mem
%chk=$name.chk
# irc=(calcfc,reverse,maxpoints=$points,stepsize=$steps) $w_fun/$w_basis $w_solcard$w_sol$w_solend scf=(xqc,maxconventionalcycle=20,tight,IntRep)
integral=grid=$w_grid temperature=$w_temp

$name  

$charge $spin
EOL
tail -n +3 $input >> $name""_reverse.com #grabs xyz minus first two lines
echo -e "\n" >> $name""_reverse.com #must have empty line in .com file
		
mkdir reverse
mv "$name""_reverse.com" reverse/


}

# below function groups the above functions

function main (){
	update_variables
	menu1 #ask for parameters
	menu2
	write_com_forward #generate com file
	write_com_reverse #generate com file

}

main
#call main function

   
#!/bin/bash -l

#======================================= End of Script ======================================================================
