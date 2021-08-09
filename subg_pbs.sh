#!/bin/bash
#hashbang line, tells the script it should use bash to interpret its content


# Script by DTE 03/14/2020
# Last update: 04/20/2020
# this script is designed to create an in situ .pbs file from a given .com input file and submit the job automatically to the MSI

# INSTRUCTIONS
# in order to use this script, create a folder called bin in your home directory via cd; mkdir bin; and save this script in the bin folder
# Then change the permissions of the script by typing in the bin directory "chmod 750 subg"
# Two methods to run script from any directory: 
# 1) call the script by typing "~/bin/subg filename.com" replacing filename as needed
# 2) edit your .bash_profile file (on MSI this seems to be identical with the .bashrc) by adding the following line
# export PATH=~/bin:$PATH
# this will allow you to source the script from anywhere you currently are in your folder tree
# to call this script type: source subg <name_of_.com_file>

# a .pbs file will be created automatically and submitted to the designated queue. The .pbs file will later be removed. If you want to keep your .pbs file
# then comment the function call tabula_rasa in the main function by adding a # in front of it
# Update History
# DTE 03/16/2020 original
# CWF 03/27/2020 removed tilde from shebang to allow for method 1 of access, added chmod instructions
# DTE 03/31/2020 the instructions to edit your .bashrc were wrong - thanks Yukun for pointing this out to me - it should be export PATH=~/bin:$PATH   colon instead of =!
# DTE 04/06/2020 added the part of the get_par function that also allows the user to enter a designated amount of processors to be used
# DTE 04/20/2020 added the joblog function, which will create a file called joblog.txt in your home directory with a log of jobs you submitted
# CWF 04/20/2020 for personal version, changed email settings and removed jokes function
# CWF 04/21/2020 for personal version, changed joblog to store path rather than only file name
#============================================= Begin of script =================================================================================


input="$1" #declares the string with name of input file
name=${input%%.com} #cuts off the .com part of the input file and saves it to variable name
path=$(readlink -f "$1")

function get_mem (){ #there might be a more elegant way to achieve this!...
	temp_mem_1=$(awk '/%mem/ {print}' "$input") #this grabs the memory from input file 
	temp_mem_2=${temp_mem_1/MB/mb} #replaces the MB from end of the line with mb
	memory=${temp_mem_2#%} #deletes the beginning of the line
#memory is now of the form mem=...mb as needed for pbs file

}

function get_par (){
	echo "Walltime in hours? (default will result in 8h)"
	read w_time

	if [ -z $w_time ];
	then
	w_time=8
	fi
	#echo $w_time

		echo "How many processors do you request for this calculation? (default will result in 32)"
        read n_procs

        if [ -z $n_procs ];
        then
        n_procs=32
        fi


	
	echo "Which queue would you like to use? (default will result in amdsmall)"
	read which_q

	if [ -z $which_q ];
	then
	which_q="amdsmall"
	fi
	
	#echo $which_q
}


function write_pbs (){
#in the following it will create the .pbs file
#the PBS -m option abe was reduced to a, this should only send out a mail to the designated contact if the job gets aborted but not for regular start and finish
cat > "$name"".pbs" << EOL 
#!/bin/bash -l

#PBS -m ae
#PBS -M $USER@umn.edu
#PBS -l nodes=1:ppn=$n_procs
#PBS -l walltime=$w_time:00:00
#PBS -l $memory
#PBS -e $name.e
#PBS -o $name.o
#PBS -q $which_q

cd \$PBS_O_WORKDIR

ulimit -s unlimited

#cd /home/working
mkdir -p /scratch/$USER/\$PBS_JOBID
export GAUSS_SCRDIR=/scratch/$USER/\$PBS_JOBID
module load gaussian/g16.c01
fix_input $name.com
/usr/bin/time g16 < $name.com >& $name.out
#rm /scratch/$USER/\$PBS_JOBID/*.rwf


 


EOL
# this will write several lines of text to the new .pbs file including some extra lines at the end!
}


function queue (){
	qsub "$name".pbs #this will submit the pbs file to the designated queue
	qstat -u $USER #this will immediately check if it has been submitted
}

function tabula_rasa (){
	rm "$name".pbs #this will delete the in situ generated .pbs file
}


function joblog (){ #this function will always write the date and time as well as the name of the job to a file called joblog.txt in your home directory
        date >> ~/joblog.txt
        echo "$path" >> ~/joblog.txt
        echo "Status: " >> ~/joblog.txt
		echo >> ~/joblog.txt
}



function main (){
	get_mem #read the info on memory from input .com
	get_par #ask for walltime and desired queue
	write_pbs #generate pbs file
	queue    #submit the pbs file to the queue
	#tabula_rasa #delete the in situ generated pbs file
	joblog
}

main
#call main function



#======================================= End of Script ======================================================================
