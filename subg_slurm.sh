#!/bin/bash
#hashbang line, tells the script it should use bash to interpret its content


# Script by Dominic Egger 03/14/2020
# Last update: 04/20/2020
# this script is designed to create an in situ slurm .sh file from a given .com input file and submit the job automatically to the MSI

# INSTRUCTIONS
# in order to use this script, create a folder called bin in your home directory via cd; mkdir bin; and save this script in the bin folder
# Then change the permissions of the script by typing in the bin directory "chmod 750 subg"
# Two methods to run script from any directory: 
# 1) call the script by typing "~/bin/subg filename.com" replacing filename as needed
# 2) edit your .bash_profile file (on MSI this seems to be identical with the .bashrc) by adding the following line
# export PATH=~/bin:$PATH
# this will allow you to source the script from anywhere you currently are in your folder tree
# to call this script type: source subg <name_of_.com_file>

# a slurm .sh file will be created automatically and submitted to the designated queue. The slurm .sh file will later be removed. If you want to keep your slurm .sh file
# then comment the function call tabula_rasa in the main function by adding a # in front of it
# Update History
# Dominic Egger 03/16/2020 original
# Connor Frye 03/27/2020 removed tilde from shebang to allow for method 1 of access, added chmod instructions
# Dominic Egger 03/31/2020 the instructions to edit your .bashrc were wrong - thanks Yukun for pointing this out to me - it should be export PATH=~/bin:$PATH   colon instead of =!
# Dominic Egger 04/06/2020 added the part of the get_par function that also allows the user to enter a designated amount of processors to be used
# Dominic Egger 04/20/2020 added the joblog function, which will create a file called joblog.txt in your home directory with a log of jobs you submitted
# Connor Frye 04/20/2020 for personal version, changed email settings and removed jokes function
# Connor Frye 04/21/2020 for personal version, changed joblog to store path rather than only file name
# Connor Frye 2022 Now creates editable database for storing variables, can make multiple subg scripts for different projects, just change database and aliases
#============================================= Begin of script =================================================================================


input="$1" #declares the string with name of input file
  if [ "${input: -4}" == ".gjf" ];
	then
	name=${input%%.gjf} #cuts off the .gjf part of the input file and saves it to variable name
	dos2unix "$1" > /dev/null 2>&1
	fi

  if [ "${input: -4}" == ".com" ];
	then
	name=${input%%.com} #cuts off the .com part of the input file and saves it to variable name
	dos2unix "$1" > /dev/null 2>&1
	fi
	#cuts off the extension of the input file (if either .com or .gjf) and saves it to variable name
path=$(readlink -f "$1")

#function get_mem (){ #there might be a more elegant way to achieve this!...
#	temp_mem_1=$(awk '/%mem/ {print}' "$input") #this grabs the memory from input file 
#	temp_mem_2=${temp_mem_1/MB/mb} #replaces the MB from end of the line with mb
#	memory=${temp_mem_2#%} #deletes the beginning of the line
#memory is now of the form mem=...mb as needed for slurm .sh file

#}

SCRIPTPATH="$(dirname "$0")"

# below function will ask for paramters

function update_variables(){
cd $SCRIPTPATH
context="script_variables_subg_slurm.db"
if [ -f $context ]; then
 echo "loading current parameters..."
else
echo "creating script_variables_subg_slurm.db to set default parameters..."
        cat > script_variables_subg_slurm.db << EOL
Number of processors=
32
Memory (mb)=
80000mb
Time=
8
queue=
msismall

# adding any extra lines above this one will break the script. Only edit the text below each respective field title!

EOL
fi

mapfile -t -O 1 var <$context
n_proc=${var[2]}
w_mem=${var[4]}
w_time=${var[6]}
which_q=${var[8]}
cd - > /dev/null
}

function default_par (){
# asks user if they want to modify parameters, if other answer is pressed assumes no
echo
echo -e "\e[0;33mThese are the default parameters:\e[0m" 
echo -e
echo -e "\e[0mProcessors =" 	$n_proc
echo "Memory =" 		$w_mem
echo "Time =" 			$w_time
echo "Queue =" 			$which_q
echo -e
echo -e "\e[92mSelect [Y, y, 1, or enter] to continue"
echo -e "\e[1;31mSelect [N, n, or 2] to exit"
echo -e "\e[35mSelect [3] to edit default parameters (using nano), re-run script once your edits are complete \e[0m"

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

function get_par (){
	echo "Walltime in hours? default will result in" ${var[6]} hours
	read w_time

	if [ -z $w_time ];
	then
	w_time=${var[6]}
	fi
	#echo $w_time

	echo "How many processors do you request for this calculation? default will result in" ${var[2]}
	read n_procs

	if [ -z $n_procs ];
	then
	n_procs=${var[2]}
	fi

	echo "How much memory do you request for this calculation? default will result in" ${var[4]}
	read w_mem

	if [ -z $w_mem ];
	then
	w_mem=${var[4]}
	fi

	
	echo "Which queue would you like to use? default will result in" ${var[8]}
	read which_q

	if [ -z $which_q ];
	then
	which_q=${var[8]}
	fi
	
	#echo $which_q
}


function write_slurm (){
#in the following it will create the slurm .sh file
#the PBS -m option abe was reduced to a, this should only send out a mail to the designated contact if the job gets aborted but not for regular start and finish
cat > "$name"".sh" << EOL 
#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=$n_procs
#SBATCH --cpus-per-task=1
#SBATCH --mem=$w_mem
#SBATCH -t $w_time:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=$USER@umn.edu
#SBATCH -p $which_q
#SBATCH -o $name.o
#SBATCH -e $name.e

cd \$SLURM_SUBMIT_DIR

ulimit -s unlimited

module load gaussian/g16.c01

mkdir -p /scratch.global/$USER/\${SLURM_JOBID}
export GAUSS_SCRDIR=/scratch.global/$USER/\${SLURM_JOBID}

/usr/bin/time g16 < $input >& $name.out
#rm /scratch.global/$USER/\${SLURM_JOBID}/*.rwf


EOL
# this will write several lines of text to the new slurm .sh file including some extra lines at the end!
}


function queue (){
	sbatch "$name".sh #this will submit the slurm sh file to the designated queue
	squeue -al --me #this will immediately check if it has been submitted
	sprio -u $USER
}

function tabula_rasa (){
	rm "$name".sh #this will delete the in situ generated slurm .sh file
}


function joblog (){ #this function will always write the date and time as well as the name of the job to a file called joblog.txt in your home directory
        date >> ~/joblog.txt
        echo "$path" >> ~/joblog.txt
        echo "Status: " >> ~/joblog.txt
		echo >> ~/joblog.txt
}

function slurmhistory-yesterday(){
d=`date +%F -d "1 day ago"`
sacct -X --starttime $d --format=JobID,Jobname%50,state,elapsed,time,end
}

function main (){
#	get_mem #read the info on memory from input .com
	update_variables
	default_par
	get_par #ask for walltime and desired queue
	write_slurm #generate slurm sh file
	queue    #submit the slurm .sh file to the queue
	# slurmhistory-yesterday
	tabula_rasa #delete the in situ generated slurm .sh file
	joblog
}

main
#call main function



#======================================= End of Script ======================================================================
