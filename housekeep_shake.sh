#!/bin/bash
#hashbang line, tells the script it should use bash to interpret its content

#housekeeping:
mkdir firstrun  #create a new directory
mv * ./firstrun/ #save all current files into this new directory
mkdir shake #create a new directory shake  where all the files will be saved that will be generated in the step of shaking and resubmitting
cd firstrun
cp *.com ../shake/ ; cp *.out ../shake/  #we need .com to read out keywords and the .out to read out last final geometry
cd ../shake/ #go to the new shake directory with old .com and .out in there to further proceed


