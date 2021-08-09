# This script is designed to create two .xyz files containing geometries corresponding to a manual displacement of an optimized TS structure
# along the imaginary frequency in both directions, optimising these geometries should ideally result in something similar to the proposed intermediates
# which are being connected by a specific transition state
# so the input of this python script should be a converged TS opt and freq .out file
# Script is for python 2!!!! Python3 will not work.

# Script by DTE 07/10/2020
# Edited by CWF 08/07/2020
# Last update: 07/10/2020

# ================================================= Begin of Script ======================================================================================

# import some python stuff

import sys
import re
import numpy as np # this will load the module to run array and calculation stuff

while True: #starts logic loop to ask for numbers (only), was originally suppose to loop back and ask question again if non-integer entered, but that didn't work so just made it exit instead
	try: #does this
		displacePlus = float(raw_input("How far do you want to displace in plus direction? (Go with 1 if unsure) "))  #asks for user input, stories as floating variable that can be used later -> gives error if don't have float
	except ValueError: #checks to make sure you put in a number
		print("Error! This is not a number. Try again.") 
		exit() #quits
	else: # for second variable
		while True:
			try:
				displaceMinus = float(raw_input("How far do you want to displace in minus direction? (Go with 1 if unsure) "))
			except ValueError:
				print("Error! This is not a number. Try again.")
				exit()
			else:
				break #tells it to end logic loop
	break #end the first loop

# start by declaring input and output file

input = sys.argv[1] # the .out file used as input is declared as input
open_input = open(input,"r") # this will open the input file in read mode

output_1 = open("plus.xyz","w") # open a new file called plus.xyz in the same directory as output file in write mode for our output
output_2 = open("minus.xyz","w") # same


# Set global variables

# For Python 2, the function raw_input() is used to get string input from the user via the command line, 
# while the input() function returns will actually evaluate the input string and try to run it as Python code.

start = 0 # this variable will mark the line where our final standard orientation section begins
end = 0
start2 = 0 # this variable will mark the line where our harmonic frequency displacement coordinate section begins

# Read input file and determine the numbers of the lines with the stuff we want

rline = open_input.readlines() # so we basically save the content from all the lines in our input file into this variable rline

for i in range (len(rline)):
    if "Standard orientation:" in rline[i]:
        start = i
		# it loops over all lines of the file and always sets the i to a new start value once it reaches a "Standard orientation" section
		# it overwrites this i everytime unless it's the last standard orientation section in the file i.e. the last structure! 
		# that's why really only get out the final geometry!

for m in range (start + 5, len(rline)): # the reason why there is a +5 is that the list of coordinates only starts five lines after the "Standard orientation
    if "---" in rline[m]:  # the Standard orientation section is terminated by a ---------------- line
        end = m
        break

	# after this we now know the line numbers of the Standard orientation section for the final geometry
	# this allows us now to calculate the total number of atoms in that section which we will later need for .xyz file format

atomnr = int(end - start - 5) #this will count the number of atoms

for i in range (len(rline)):  
    if "Harmonic frequencies" in rline[i]: 	# this will find us the line where the displacement coordinate section begins
	start2 = i
# we will only need the displacement vectors for the lowest harmonic frequency, this is the imaginary for a TS

# now let's save the atom coordinates and displacement coordinates of the imaginary mode into arrays

A = np.empty([atomnr,3]) # this will be the 2D array for the standard orientation coordinates

i = 0 # define loop-internal running variable #C++ style
for line in rline[start+5 : end] : # so this loop runs over the standard orientation section
	coord = line.split() # split the content on that particular line and then assign the content of xyz columns to the array
	A[i][0] = float(coord[3])
	A[i][1] = float(coord[4])
	A[i][2] = float(coord[5])
	# the xyz coordinates are in columns 4,5 and 6
	i = i+1

# print(A)	# for the user to quickly check, turned off to prevent clutter, turn back on if interested

B = np.empty([atomnr,3])	# initialize a defined array with 3 columns and the nr of atoms for the rows 
			 	# this will be the array for the displacement vector increments

				# note that in a Gaussian output file the first displacement coordinates are listed 11 lines after "Harmonic frequencies"
i = 0 # loop internal running variable
for line in rline[start2+11 : start2+11+atomnr] : #loop over all displacement coordinates
	coord = line.split()
	B[i][0] = float(coord[2])
        B[i][1] = float(coord[3])
        B[i][2] = float(coord[4]) 
	# the displacement coordinates are in column 3,4 and 5
	i = i+1

# print(B)	# for the user to quickly check, turned off to prevent clutter, turn back on if interested

# now let's write two new .xyz files!

	# this Conversion section was adapted from the shake.py script 
	# Gaussian normally does not have problems if an element symbol is being replaced by its atomic number

C = A + (displacePlus*B) # plus geometry multiplied by coefficient variable
D = A - (displaceMinus*B) # minus geometry multiplied by coefficient variable

print >> output_1, "%s" % (atomnr)  # this should print the atomnr at the start of each new structure as needed for .xyz file format
output_1.write("\n") 
	 # this should print a newline after the atom number, I think titles in multi structure .xyz are optional
	
print >> output_2, "%s" % (atomnr) # print atomnr
output_2.write("\n")
	
j = 0 # additional running variable to make it easier to call specific lines of C- and D-array
for line in rline[start+5 : end] : # inner for loop over all atoms to write the xyz coordinates of one structure
 		words = line.split()
    		word1 = int(words[1])
		
		# Periodic Table Section
    		if word1 == 17 :
        		word1 = "Cl"
   		elif word1 == 9 :
        		word1 = "F "
    		elif word1 == 35 :
        		word1 = "Br"
    		elif word1 == 5 :
        		word1 = "B "
    		elif word1 == 46 :
        		word1 = "Pd"
    		elif word1 == 6 :
        		word1 = "C "
    		elif word1 == 1:
        		word1 = "H "
    		elif word1 == 7:
        		word1 = "N "
    		elif word1 == 8:
        		word1 = "O "
    		elif word1 == 22:
        		word1 = "Ti "
    		elif word1 == 14:
        		word1 = "Si "
		elif word1 == 16:
			word1 = "S " 
		#change all the integers into correct atom symbol
    
		print >>output_1, "    %s      %s   %s   %s" % (word1,C[j][0],C[j][1],C[j][2])
		
		print >>output_2, "    %s      %s   %s   %s" % (word1,D[j][0],D[j][1],D[j][2]) 
    		j = j + 1
	
	# once the for loop is complete, you should get two new .xyz files

# this section can be activated to test if everything works properly by printing out a couple of the variables generated along the way

#	print(atomnr) 
#	print(start)
#	print(end)
#	print(start2)
#	print(A)
#	print(B) 
#	C = A + B
#	print(C)
# 	D = A - B
# 	print(D)


# end by closing the files you had previously opened

open_input.close() #close the input file
output_1.close() #close the first finished output file
output_2.close() #close second finished output file


# ================================================= End of Script ========================================================================================
