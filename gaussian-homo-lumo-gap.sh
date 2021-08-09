#!/bin/sh
# gaussian-homo-lumo-gap.sh - extract values from Delta-SCF Gaussian calculations

for i in *.out
do
    # grabs the homo lumo in different energies and calculates gap
    HOMO=` grep "occ" "${i}" | tail -n 1 ` # grabs the first occurance of occupied orbital from the end of the file and (going up)
    HOMOh=` grep "occ" "${i}" | tail -n 1 | awk '{print $NF*1}' ` # grabs the last number in the line and multiplies by unit conversion
    HOMOe=` grep "occ" "${i}" | tail -n 1 | awk '{print $NF*27.2114}' `
    HOMOk=` grep "occ" "${i}" | tail -n 1 | awk '{print $NF*627.509}' `
    LUMO=` grep -A 1 "occ" "${i}" | tail -n 1 ` # grabs the line after the first occurrance occupied orbital (A=after, B=before, C=both, 1 is number of lines)
    LUMOh=` grep -A 1 "occ" "${i}" | tail -n 1 | awk '{print $5*1}' ` # grabs first number in the line and multiplies by unit conversion
    LUMOe=` grep -A 1 "occ" "${i}" | tail -n 1 | awk '{print $5*27.2114}' `
    LUMOk=` grep -A 1 "occ" "${i}" | tail -n 1 | awk '{print $5*627.509}' `
    GAPe=` echo "${LUMOe} - ${HOMOe}" | bc -l ` # subtracts for gap
    GAPh=` echo "${LUMOh} - ${HOMOh}" | bc -l `
    GAPk=` echo "${LUMOk} - ${HOMOk}" | bc -l `
    
    echo -e "\e[1;4m ${i}"
    echo -e "\e[0;36m HOMO = ${HOMO}"
    echo -e "\e[92m LUMO = ${LUMO}"
    echo -e "\e[36m HOMO: " ; echo "${HOMOh} hartree" ; echo "${HOMOe} eV"; echo "${HOMOk} kcal/mol"
    echo -e "\e[92m LUMO: " ; echo "${LUMOh} hartree" ; echo "${LUMOe} eV" ; echo "${LUMOk} kcal/mol"
    echo -e "\e[93m GAP: " ; echo "${GAPh} hartree" ; echo "${GAPe} eV" ; echo -e "${GAPk} kcal/mol \e[0m"

 #   # These are the Delta-SCF total energies; from 'SCF Done' line in Gaussian output
  #  neutral=` grep "SCF Done" "${i}" | awk '{print $5}' `
   # cation=` grep "SCF Done" "${i/neutral/cation}" | awk '{print $5}' `
   # anion=` grep "SCF Done" "${i/neutral/anion}" | awk '{print $5}' `

    # Calculate IP and EA with maths & scale to eV
   # IP=` echo "(${cation} - ${neutral} ) * 27.2114" | bc -l `
   # EA=` echo "(${neutral} - ${anion} ) * 27.2114" | bc -l `

    #echo -n "IonisationPotential: ${IP} ElectronAffinity: ${EA} "
    #echo -n "FundamentalGap: "
    #echo "${IP} - ${EA}" | bc -l
done
