#!/bin/bash

#Note to new users: Change file path at line 27 (marked by ###) to home directory

#The code is more afraid of you than you are of it. - B.R.R
#Last update 6/17/2018

#instructions/warning
echo
echo "this script scrapes Gaussian 016 outputs for HOMO/LUMO energies,"
echo "atomic Mulliken charges, and calculated isotropic NMR shifts - "
echo "blank outputs mean an unexpected Gaussian file format or an uncalculated parameter"
echo
echo "the script includes only basic handling - use protection and sanitize your data"
echo
echo "if script fails at start up make sure line 27 is changed to personal home directory"
echo
echo "follow the instructions and see how justs far the rabbit hole goes"

#identify file name
echo
echo "What is the name of your file? "
read text1

#identify file location
#######################
text2=$(find ~/Desktop/PCA/secondtry/calculations -name "$text1.out" -exec dirname {} \;)
#######################
childlock=$(echo -n "$text2" | wc -c )

#error handling
until [ $childlock -gt 4 ]; do
  if [ -z "$text2" ]; then
      echo
      echo "No file named $text1 could be found, just like my dignity"
      echo
  fi
echo "What is the name of your file? "
read text1
text2=$(find ~/Desktop/PCA/secondtry/calculations -name "$text1.out" -exec dirname {} \;)
childlock=$(echo -n "$text2" | wc -c )
done

#identify atom for Mulliken charges (write atomic symbol in proper case - e.g. N for nitrogen)
echo
echo "Which atom's Mulliken charge would you like displayed?"
read text3

#identify number of atoms in structure
natoms=$(cat $text2/$text1.out | grep -m 1 NAtoms | cut -c 9-14 | tr -d "[:blank:]")

#search and extract isotropic NMR parameters from .out file
#search for keywords
grep -w -n Isotropic $text2/$text1.out > $text2/NMR.txt
#delete last line of output
sed -i '.bak' '$d' $text2/NMR.txt
#parse output
rm -f $text2/NMRfinal.txt $text2/temp.txt
count=1
while read -r line; do
      head -n $count $text2/NMR.txt | tail -n +$count | tr -s "[:space:]" "," | cut -d',' -f2,3,6 >> $text2/temp.txt
      element=$(head -n $count $text2/temp.txt | tail -n +$count | cut -d',' -f2)
        if [ $element == "C" ] || [ $element == "H" ];then
          head -n $count $text2/temp.txt | tail -n +$count >> $text2/NMRfinal.txt
        fi
count=$(( $count + 1 ))
done < $text2/NMR.txt
#title csv file
echo 'atomindex,atom,unscaledchemicalshift' | cat - $text2/NMRfinal.txt > temp && mv temp $text2/NMRfinal.txt

#find Mulliken charges at designated atoms
#search and extract final Mulliken charges
count=$(( $natoms + 1 ))
grep -B $natoms 'Sum of Mulliken charges' $text2/$text1.out | tail -n $count | head -n $natoms > $text2/temp.txt
#parse output
count=1
rm -f $text2/Mulliken.txt
while read -r line; do
      grep $text3 $text2/temp.txt| head -n $count | tail -n +$count | tr -s "[:space:]" "," | cut -d',' -f2,3,4 >> $text2/Mulliken.txt
count=$(( $count + 1 ))
done < $text2/temp.txt

#find HOMO/LUMO energies
HOMO=$(grep 'Alpha  occ. eigenvalues' $text2/$text1.out | tail -1 | tr -s "[:space:]" "," | rev | cut -d',' -f2 | rev)
LUMO=$(grep -A 1 'Alpha  occ. eigenvalues' $text2/$text1.out | tail -1 | tr -s "[:space:]" "," | cut -d',' -f6)

#output
echo
echo "Mulliken charges:"
cat $text2/Mulliken.txt
echo
echo "HOMO energy/LUMO energy:"
echo "$HOMO/$LUMO"
echo
cat $text2/NMRfinal.txt
echo
echo "remember NMR scaling parameters are:"
echo "1H: slope: -1.0183; intercept: 32.3395"
echo "13C: slope = -0.9349; intercept = 192.1504"
echo "ref: http://cheshirenmr.info/ScalingFactors.htm#table1aheading"

#housekeeping
rm -f $text2/NMR.txt $text2/NMR.txt.bak $text2/temp.txt $text2/Mulliken.txt

#tells a random joke on completion
let "rand=$RANDOM %11"
case "$rand" in
  "0") echo
       echo "What do you call cheese that isn't yours?"
       echo "Nacho cheese"
  ;;
  "1") echo
       echo "How many tickles does it take to make an octopus laugh?"
       echo "Ten tickles"
  ;;
  "2") echo
       echo "Is your refrigerator running?"
       echo "Better go catch it"
  ;;
  "3") echo
       echo "Did you hear about the guy who invented Lifesavers?"
       echo "They say he made a mint"
  ;;
  "4") echo
       echo "Why do chicken coops only have two doors?"
       echo "Because if they had four they would be chicken sedans"
  ;;
  "5") echo
       echo "Do you want to hear a chemistry joke?"
       echo "NaBrO"
  ;;
  "6") echo
       echo "Why did Kepler get fired from his janitor position"
       echo "He only swept out the same area."
  ;;
  "7") echo
       echo "Did you hear oxygen went on a date with potassium?"
       echo "It went OK."
  ;;
  "8") echo
       echo "What did the photon say when the airport security asked about luggage?"
       echo "I don't have any luggage, I'm traveling light."
  ;;
  "9") echo
       echo "Do you think organic chemistry is hard?"
       echo "I hear its alkynes of trouble."
  ;;
  "10") echo
      echo "Why does the army stockpile HCl?"
      echo "To analyze enemy bases."
  ;;
 esac
