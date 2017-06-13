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

#---------------------------------------
# Transfer files with rsync by directory
# Globals:
#   logpath
# Arguments:
#   $1 -> Source volume
#   $2 -> Destination volume
#   $3 -> target dircotry
# Returns:
#   None
#---------------------------------------

trans () {
  vol_src=$1
  vol_dest=$2
  target_dir=$3

  echo "*** target dir : $target_dir ***" | tee -a $logpath

  rsync $option $vol_src/$target_dir $vol_dest/from_${vol_src#/}/ 2>> $logpath
  err_chk $? "command : rsync"
}

#---------------------------------------
# Transfer files between source to destination volume
# Globals:
#   logpath
# Arguments:
#   $1 -> Source volume
#   $2 -> Destination volume
# Returns:
#   None
#---------------------------------------

process () {
  vol_src=$1 
  vol_dest=$2

  dirs_vol_src=($(ls $vol_src))

  echo "*****************************" | tee -a $logpath
  echo "*** $vol_src -> $vol_dest ***" | tee -a $logpath
  echo "*****************************" | tee -a $logpath

  for dir in "${dirs_vol_src[@]}"
  do
    trans $vol_src $vol_dest $dir
    err_chk $? "fuction : trans"
  done
}

##############################
# Test
##############################

#trans /data2 /data5 test_dir
#err_chk $? "trans : test_dir"
#exit

##############################
# Main
##############################

# ----------------------------------------
# Initailization
# ----------------------------------------

rm -f $logpath

if [ ! -e $logpath ]; then
  touch $logpath
fi

echo "Start from $(date +"%Y/%m/%d %H:%M:%S")" | tee -a $logpath

# ----------------------------------------
# Migration
# ----------------------------------------

# /data2 -> /data5
process /data2 /data5
err_chk $? "fuction : process"

