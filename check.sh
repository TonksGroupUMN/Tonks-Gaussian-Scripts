#!/bin/bash
#hashbang line, tells the script it should use bash to interpret its content


# Script by DTE 03/18/2020
# Edited by CWF
# Last update: 10/05/2020
# this script is designed to read out valuable things from a Gaussian output file

# INSTRUCTIONS
# in order to use this script, create a folder called bin in your home directory via cd; mkdir bin; and save this script in the bin folder
# edit your .bash_profile file (on MSI this seems to be identical with the .bashrc) by adding the following line
# export PATH=~/bin=$PATH
# this will allow you to source the script from anywhere you currently are in your folder tree
# to call this script type: source check  <name_of_.out_file>

#================================================ Begin of Script ===========================================================================

if
[ ! -f *.out ]
then
echo "Dude, where's my .out?"
exit
fi
echo -e "\e[0m"
echo
echo -e "\e[1;36m The version of gaussian used was: \e[0m"
grep -E -o -m 1 ".{0,0}/gaussian/.{0,7}" $1
echo -e "\e[0m"
echo
echo -e "\e[1;36m The calculation parameters used were: \e[0m"
grep -A 3 "#" $1 | head -n 2
echo
echo -e "\e[0;92m Quick check if Gaussian terminated normally or if potentially an error occured: \e[0m"

grep "Normal termination" $1
grep "Stationary point found." $1
echo -e "\e[0m"
echo
read -p "Press enter to continue"
echo


echo "Let's see if your job has successfully converged:"
grep -A7 Converged $1
echo 
echo

structures="$(grep -c "Converged?" $1)"
echo -e "\e[1;36m Calculation Stats:\e[0m"
echo -e "\e[1;36m ------------------\e[0m"
echo -e "\e[1;36m Number of Structures: $structures \e[0m"

echo

echo "Check for number of imaginary modes. For an intermediate it should be 0, for a TS it should be exactly 1!"
grep NImag $1
echo
echo

# read -p "Press enter to continue"
echo

echo "At last, let's see if we have any frequencies below 50cm^-1 and need to apply the correction script:"
grep -A9 "Harmonic frequencies" $1
echo



#=============================================== End of Script =================================================================================
