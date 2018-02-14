#!/bin/bash
#
# Data migration script by volume

##############################
# Variables
##############################

#readonly comp=-z
#readonly dry=--dry-run
#readonly del=--delete
readonly option="-avh $comp $dry $del"

readonly workdir=$PWD
readonly script_name=${0##*/}
readonly base=${script_name%.sh}
readonly logfname=${base}.log
readonly tmpfname=${base}.tmp
readonly logpath=$workdir/log/$logfname
readonly tmppath=$workdir/$tmpfname

##############################
# Functions
##############################

#---------------------------------------
# Error-check return code of command
# Globals:
#   logpath
# Arguments:
#   $1 -> Return code of previous command
#   $2 -> Error message
# Returns:
#   None
#---------------------------------------

err_chk () {
  if [ $1 -ne 0 ]; then
    echo "Error occured in $2" | tee -a $logpath
    exit
  fi
}

##############################
# Main
##############################

target_dirs=(
  AAA \
  BBB \
)

vol_from=/data0

for dir in "${target_dirs[@]}"
do
  echo "removing ${vol_from}/${dir} ..."
  rm -rf ${vol_from}/${dir} 
  err_chk $? "rm : ${dir}"
done

exit
