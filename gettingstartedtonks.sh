#!/bin/bash

#============================================= Begin of script =================================================================================

cat >> ~/.bash_aliases <<'EOL'
#########
# These are aliases to call scripts
# Some aliases are disabled or retired and are commented out like this
#########
alias subg="~/bin/subg_slurm.sh" # -- this script submits to slurm
alias sub_molpro="~/bin/sub_molpro_slurm.sh" # -- this script submits molpro calcs for slurm
alias check="/panfs/roc/groups/13/itonks/$USER/bin/check.sh" # -- this script checks gaussian output files
alias xyz2com="/panfs/roc/groups/13/itonks/$USER/bin/xyz2com.sh" # -- converts xyz to com
alias input2xyz="~/bin/input2xyz.sh"
alias com2xyz="/panfs/roc/groups/13/itonks/$USER/bin/com2xyz.sh" # -- converts com to xyz
alias gjf2xyz="~/bin/gjf2xyz.sh"
alias getxyz="/panfs/roc/groups/13/itonks/$USER/bin/getxyz.sh" # -- extracts .xyz from .out
alias getall="/panfs/roc/groups/13/itonks/$USER/bin/getallxyz3.sh"
alias getall2="/panfs/roc/groups/13/itonks/$USER/bin/getallxyz4.sh"
alias modcom="/panfs/roc/groups/13/itonks/$USER/bin/modcom.sh" # -- modifies existing .com files quickly
alias modcomirc="/panfs/roc/groups/13/itonks/$USER/bin/modcomirc.sh" # -- modifies existing irc .com files
alias xyz2comp="/panfs/roc/groups/13/itonks/$USER/bin/xyz2comp.sh" # -- converts .xyz to .com for pseudo calc
alias xyz2ibocom="/panfs/roc/groups/13/itonks/$USER/bin/xyz2ibocom.sh" # -- converts .xyz to .com for a ibo calc
alias xyz2com_pm6="/panfs/roc/groups/13/itonks/$USER/bin/xyz2com_pm6.sh" # -- converts .xyz to .com for a pm6 calc
alias mktscom="/panfs/roc/groups/13/itonks/$USER/bin/mktscom.sh" # -- makes a ts .com from given input files
alias correct="/panfs/roc/groups/13/itonks/$USER/bin/freq_replacement_g09_2_0.pl" # -- corrects free energy to account for low frequencies
alias correctts="/panfs/roc/groups/13/itonks/$USER/bin/freq_replacement_g09_2_0.pl --isTS" # -- ditto but for ts
alias fakeirc="python /panfs/roc/groups/13/itonks/$USER/bin/fakeIRC_cf.py" # -- manual displacement of imaginary frequency
alias fchk="formchk *.chk" # -- quickly convert .chk to .fchk
alias formatchk="formchk *.chk" # -- ditto
alias gap="/panfs/roc/groups/13/itonks/$USER/bin/gaussian-homo-lumo-gap.sh"
alias smile="~/bin/smiles2xyz.sh"

###########
# These are useful shortcut aliases for common commands
# Some shortcuts are disabled by default, enable them by deleting # if desired
###########
alias up="cd .. ; ls -A" # go up folder level and show files
alias del="scancel" # -- used to delete jobs from queue
alias sb="source ~/.bashrc" # load bash files edits quickly
alias vb="vi ~/.bashrc" # edit the bash file from anywhere
alias vc="vi ~/.vimrc" # edit the vimrc file from anywhere
alias vic="vi *.com" # quickly edit .com files
alias vio="vi *.out" # quickly edit .out files
alias vix="vi *.xyz" # quickly edit .xyz files
alias ac="acctinfo -n" # live account info
alias onlycom="rm *.out ; rm *.sh ; rm *.e ; rm *.o ; rm *.chk ; rm fort* ; rm core*" # deletes all but .com & .xyz
alias onlyout="rm *.com ; rm *.pbs ; rm *.e ; rm *.o ; rm *.chk ; rm fort* ; rm core*" # deletes all but .out & .xyz
alias gvo="/panfs/roc/msisoft/gaussian/gaussview/Gv-6.0.16/gview.exe" # launch remote gauss view
alias home="cd ~" # go to home folder
alias energy="grep GTot *out" #get structure energy
alias jobt='grep -A1 "Job cpu" *out'
alias gg="qb > ~/lasttime.txt" # save queue list to a text file when done for the day to remind later
alias go="cat ~/lasttime.txt" # print queue list from last time into terminal
alias jobv="cat ~/joblog.txt" # read/edit "notebook"
alias jobe="vi ~/joblog.txt" # quickly edit notebook
alias snap="cp -r *.out snap.out ; vi snap.out" # save snapshot of .out
alias edit="nano"
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../'
alias cf=mycd # this will allow you to use cf instead of cd, seeing folder list when navigating to them
alias nn="nano"
alias last="tail -n 50" # prints last 50 lines of a file into terminal
alias qrc="qredocalc" #quickly do xyz2com_mNHC
alias qs="quicksave *.out" # save backup
alias ll="last *.out ; check *.out" #check progress
alias mc="modcom *.com" # quickly do modcom
alias sg="subg *.com" #submit quickly
alias cc="check *.out" # quickly check .out
# These aliases require below functions to work
alias ql="slurmhistory-yesterday"
alias qlm="slurmhistory-month"
alias qla="slurmhistory-all"
alias hl="/panfs/roc/groups/13/itonks/$USER/bin/hl/hl" # this alias will not work if hl is not installed/in right directory
alias lo="ql"
alias lp="ql"

####
# These are modifications or replacements of default commands, use with care
####
# alias vi="nano" # note alt+/ will go to bottom of file in nano
alias mkdir='mkdir -v'
alias mv='mv -i'
alias cp='cp -i'

# This is a convoluted way to get frequency outputs from correction txt in a perfect SI format with "freqs", replaces freqc
alias freqs="freqcn; freqfn; freqfn2; freqfn3; freqfn4; freqfn5; freqfn6; freqfn7; freqfn8; freqfn9; freqfn10; freqfn11; rm freqc*"
alias freqc="freqd; freqb; freqa ; freqw"
alias freqa="grep 'The Corrected Thermal Free Energy (Hartrees):' *.txt"
alias freqb="grep 'The Thermal Free Energy (Hartrees):' *.txt"
alias freqd="grep -m 1 'The electronic energy (Hartrees):' *.txt"
alias freqw="grep 'WARNING' *.txt"
alias freqan="grep 'The Corrected Thermal Free Energy (Hartrees):' *.txt >> freqctemp.tmp"
alias freqbn="grep 'The Thermal Free Energy (Hartrees):' *.txt >> freqctemp.tmp"
alias freqdn="grep -m 1 'The electronic energy (Hartrees):' *.txt > freqctemp.tmp"
alias freqwn="grep 'WARNING' *.txt >> freqctemp.tmp"
alias freqcn="freqdn; freqbn; freqan ; freqwn"
alias freqfn="sed -e 's/          / /g' freqctemp.tmp > freqctemp2.tmp"
alias freqfn2="sed -e 's/        / /g' freqctemp2.tmp > freqctemp3.tmp"
alias freqfn3="sed -e 's/       / /g' freqctemp3.tmp > freqctemp4.tmp"
alias freqfn4="sed -e 's/The //g' freqctemp4.tmp > freqctemp5.tmp"
alias freqfn5="sed -e 's/Thermal /Gibbs /g' freqctemp5.tmp > freqctemp6.tmp"
alias freqfn6="sed -e 's/ (Hartrees):/:/g' freqctemp6.tmp > freqctemp7.tmp"
alias freqfn7="sed -e 's/electronic/Electronic/g' freqctemp7.tmp > freqctemp8.tmp"
alias freqfn8="sed -e 's/Corrected Gibbs/Corrected/g' freqctemp8.tmp > freqctemp9.tmp"
alias freqfn9="sed -e 's/Energy/energy/'g freqctemp9.tmp > freqctemp10.tmp"
alias freqfn10="sed -e 's/Free/free/'g freqctemp10.tmp > freqctemp11.tmp"
alias freqfn11="cat freqctemp11.tmp"

#####################
# ---- Functions here -----------------------------------------------------------------------------------------------------------
#####################

# This function will display stuff when you cd into a folder, but requires use of different command than cd, I use cf, alias above
function mycd() {
  cd "$1"
  ls
}

#this allows you to do a quick frequency correction and create a file from it too
function frecor() {
input="$1"
name=${input%%.out}
correct "$1" > $name""_c.txt
freqc
}

# same but for TS
function frecorts() {
input="$1"
name=${input%%.out}
correct --isTS "$1" > $name""_c.txt
freqc
}

#quick replacement xyz to com
function redocalc() {
input="$1"
name=${input%%.out}
getxyz "$1"
xyz2com $name"".xyz
subg $name"".com
}

# quick chemdraw to pm6 optimization
function s6() {
module load openbabel
#input="$1"
#echo "filename?"
#read w_name
smile "$1"
# mv "$1".xyz "$w_name".xyz
xyz2com_pm6 *.xyz
# rm *.sdf
subg *.com
module unload openbabel
}

#quickest replacement xyz to com
function qredocalc() {
input="$1"
name=${input%%.out}
getxyz "$1"
xyz2com_mNHC $name"".xyz
subg $name"".com
}

# make backup before a restart
function quicksave(){
input="$1"
name=${input%%.out}
d=`date +%F-%T`
mkdir "$d"_"$name"
cp $name.out "$d"_"$name"
cp $name.com "$d"_"$name"
cp $name.chk "$d"_"$name"
cp $name.xyz "$d"_"$name"
}

function slurmhistory-yesterday(){
d=`date +%F -d "1 day ago"`
sacct -X --starttime $d --format=JobID,Jobname%50,state,elapsed,time,end
squeue -al --me
}

function slurmhistory-month(){
d=`date +%F -d "30 day ago"`
sacct -X --starttime $d --format=JobID,Jobname%50,state,elapsed,time,end
}

function slurmhistory-all(){
d=`date +%F -d "100000 day ago"`
sacct -X --starttime $d --format=JobID,Jobname%50,state,elapsed,time,end
}
EOL

source ~/.bash_aliases
chmod -R 750 ~/bin

#======================================= End of Script ======================================================================
