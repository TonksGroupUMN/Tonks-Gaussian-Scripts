# Loads the sys to additional input in the line
# Loads the re search function

import sys
import re

# Set global variables
start = 0
end = 0

# This comes from the input
# Gives the name to a possible new file

filename = sys.argv[1]

# Open the original file in read mode

openold = open(filename,"r")
# Read the entire original file

rline = openold.readlines()

for i in range (len(rline)):
    if "Standard orientation:" in rline[i]:
        start = i
#it loops over all lines and always sets the i to a new start value, it overwrites this i everytime unless it's the last structure! that's why we really
#only get out the final geometry!
for m in range (start + 5, len(rline)):
    if "---" in rline[m]:
        end = m
        break

for j in range (len(rline)): #for-loop, define a running variable j that can span the whole nr of lines in .out file 
    if "Harmonic frequencies" in rline[j]:
	start2 = j		#once we reached the section with the harmonic frequencies it will remember the nr. of the corresponding line


#if this doesn't work I define the nr. of atoms as rline[start] - rline[end] or so then I also know how many lines to read!
atomnr = int(end - start - 5) #this will count the nr of atoms
 




# note that in a Gaussian output file the first displacement coordinates are listed on line 12 after "Harmonic frequencies" 

import numpy as np #this will load the module to run this array stuff


A = np.empty([atomnr,3]) #this will be the array for the standard orientation coordinates
i = 0 #define loop-internal running variable

for line in rline[start+5 : end] : #so this loop runs over the standard orientation section
	A[i][0] = float(line[37:46])
	A[i][1] = float(line[49:58])
	A[i][2] = float(line[61:70])
	i = i+1

#print(A)	

B = np.empty([atomnr,3]) #initialize a defined array with 3 columns and the nr of atoms for the rows #this will be the array for the displacement vector increments

i = 0 #let's do this C++ style, define a running variable
for vibline in rline[start2+11 : start2+11+atomnr] : #loop over all displacement coordinates
	B[i][0] = float(vibline[14:19])
	#this should set the first element of the nth row in the B array to the value of X 
	B[i][1] = float(vibline[21:26])
	B[i][2] = float(vibline[28:33]) #this should read in my desired parameters!
	i = i+1


#print(B)

C = A + B 

#print(C)

#with this we have added up the coordinates with lowest frequency displacement, could easily put a factor in front of B to scale the displacement up!

output = open("py.xyz","w")
# Create a new file with writing rights

# Conversion section
i = 0
for line in rline[start+5 : end] :
    words = line.split()
    word1 = int(words[1])
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
#change all the integers into correct atom symbol
    print >>output, "%s      %s   %s   %s" % (word1,C[i][0],C[i][1],C[i][2])
    i = i + 1

openold.close() #close the input file
output.close() #close the finished output file




