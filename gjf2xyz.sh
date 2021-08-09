#!/bin/bash

#hashbang line, tells the script it should use bash to interpret its content

# Script by CWF, adapted from github script and subg by DTE
# this script is designed to create a .xyz file from a given .com file 
# Please note, currently this script only works if .com has 10 lines before xyz (starts line 11), easy to adjust, change +11 on tail command
# also because of above, does not work on qst3 / qst2 type com files with more than one input coordinates

# INSTRUCTIONS
#create an alias in .bashrc or other bash profile
#call script using alias command and type filename, "alias filename.com"

# Update History
# CWF 04/24/2020 original version
#============================================= Begin of script =================================================================================

input="$1" #declares the string with name of input file
name=${input%%.gjf} #cuts off the .gjf part of the input file and saves it to variable name


function write_xyz (){ # makes temporary xyz to grab xyz coordinates without route card and then remove any blank lines from com file 

echo "" > $name""new99.xyz
tail -n +11 $input >> $name""new99.xyz #grabs xyz minus first two lines
sed -i '/^$/d' $name""new99.xyz # removes blank lines

# to final file counts number of lines to get number of atoms, add title card / comment, then takes coordinates from temp file
wc -l $name""new99.xyz > $name.xyz # counts lines
echo "$name" >> $name.xyz # adds title / comment
cat $name""new99.xyz >> $name.xyz #grabs temp file 
sed -i "1 s/$name""new99.xyz//" $name.xyz # removes temp name card

}

function overwrite (){

rm $name""new99.xyz # remove temp file

}

# below function groups the above functions

function main (){

	write_xyz #generate xyz file using temp and final file
	overwrite # remove temp file

}

main #call main function

#!/bin/bash -l

#======================================= End of Script ======================================================================
