#!/bin/bash
#
# Check whether file is damaged or not by CRC checksum

########################################
# Variables
########################################

readonly workdir=$PWD
readonly script_name=${0##*/}
readonly base=${script_name%.sh}
readonly logfname=${base}.log
readonly tmpfname=${base}.tmp
readonly logpath=$workdir/log/$logfname
readonly tmppath=$workdir/$tmpfname

#echo "logfname = $logfname"
#echo "tmpfname = $tmpfname"
#exit

########################################
# Functions
########################################

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
    exit 1
  fi
}

#---------------------------------------
# Create checksum strings by directory
# Globals:
#   logpath
#   tmppath
# Arguments:
#   $1 -> Source volume
#   $2 -> Destination volume
#   $3 -> target dircotry
# Returns:
#   None
#---------------------------------------

check () {
  local vol_src=$1
  local vol_dest=$2
  local target_dir=$3

  echo "*** target dir : $target_dir ***" | tee -a $logpath

  local vol_name=${vol_src#/}

  if [ ! -e $workdir/src/$vol_name ]; then
    mkdir -p $workdir/src/$vol_name
  fi
  if [ ! -e $workdir/dest/$vol_name ]; then
    mkdir -p $workdir/dest/$vol_name
  fi

  # Check for source directory
  echo "$vol_src : $target_dir" | tee -a $logpath

  pushd $vol_src > /dev/null

  echo "find, sort and sed" | tee -a $logpath
  find $target_dir -type f | sort | sed -e "s/^/\"/" -e "s/$/\"/" > $tmppath 2>> $logpath
  err_chk $? "find, sort and sed" | tee -a $logpath

  echo "cat and cksum" | tee -a $logpath
  cat $tmppath | xargs cksum > $workdir/src/$vol_name/cksum_$target_dir 2>> $logpath
  err_chk $? "cat and cksum" | tee -a $logpath

  popd > /dev/null

  # Check for destination directory
  echo "$vol_dest : $target_dir" | tee -a $logpath

  pushd $vol_dest > /dev/null

  echo "find, sort and sed" | tee -a $logpath
  find $target_dir -type f | sort | sed -e "s/^/\"/" -e "s/$/\"/" > $tmppath 2>> $logpath
  err_chk $? "find, sort and sed"

  echo "cat and cksum" | tee -a $logpath
  cat $tmppath | xargs cksum > $workdir/dest/$vol_name/cksum_$target_dir 2>> $logpath
  err_chk $? "cat and cksum"

  popd > /dev/null
}

#---------------------------------------
# Create checksum strings by directory
# Globals:
#   logpath
#   tmppath
# Arguments:
#   $1 -> Source volume
#   $2 -> Destination volume
#   $3 -> target dircotry
# Returns:
#   None
#---------------------------------------

check_ () {
  local vol_src=$1
  local vol_dest=$2
  local target_dir=$3

  echo "*** target dir : $target_dir ***" | tee -a $logpath

  local vol_name=${vol_src#/}

  if [ ! -e $workdir/src/$vol_name ]; then
    mkdir -p $workdir/src/$vol_name
  fi
  if [ ! -e $workdir/dest/$vol_name ]; then
    mkdir -p $workdir/dest/$vol_name
  fi

  # Check for source directory
  echo "$vol_src : $target_dir" | tee -a $logpath

  pushd $vol_src > /dev/null

  echo "find, sort and sed" | tee -a $logpath
  find $target_dir -type f | sort | sed -e "s/^/\"/" -e "s/$/\"/" > $tmppath 2>> $logpath
  err_chk $? "find, sort and sed" | tee -a $logpath

  echo "cat and cksum" | tee -a $logpath
  cat $tmppath | xargs cksum > $workdir/src/$vol_name/cksum_$target_dir 2>> $logpath
  err_chk $? "cat and cksum" | tee -a $logpath

  popd > /dev/null

  # Check for destination directory
  echo "$vol_dest : $target_dir" | tee -a $logpath

  pushd $vol_dest/from_$vol_name > /dev/null

  echo "find, sort and sed" | tee -a $logpath
  find $target_dir -type f | sort | sed -e "s/^/\"/" -e "s/$/\"/" > $tmppath 2>> $logpath
  err_chk $? "find, sort and sed"

  echo "cat and cksum" | tee -a $logpath
  cat $tmppath | xargs cksum > $workdir/dest/$vol_name/cksum_$target_dir 2>> $logpath
  err_chk $? "cat and cksum"

  popd > /dev/null
}

#---------------------------------------
# Compare checksum strings by directory
# Globals:
#   logpath
# Arguments:
#   $1 -> Source volume
#   $2 -> Destination volume
#   $3 -> target dircotry
# Returns:
#   None
#---------------------------------------

compare () {
  local vol_src=$1
  local vol_dest=$2
  local target_dir=$3

  local vol_name=${vol_src#/}

  if [ ! -e diff/$vol_name ]; then
    mkdir -p diff/$vol_name
  fi

  echo "*** diff : $vol_src/$target_dir <-> $vol_dest/$target_dir ***" | tee -a $logpath

  diff -u $workdir/src/$vol_name/cksum_$target_dir $workdir/dest/$vol_name/cksum_$target_dir > $workdir/diff/$vol_name/diff_$target_dir 2>> $logpath
  err_chk $? "diff"
}

#---------------------------------------
# Checksum and compare each volume
# Globals:
#   logpath
# Arguments:
#   $1 -> Source volume
#   $2 -> Destination volume
# Returns:
#   None
#---------------------------------------

process () {
  local vol_src=$1 
  local vol_dest=$2

  local dir_home_old=($(ls $vol_src))

  echo "*****************************" | tee -a $logpath
  echo "*** $vol_src -> $vol_dest ***" | tee -a $logpath
  echo "*****************************" | tee -a $logpath

  for dir in "${dir_home_old[@]}"
  do
    check $vol_src $vol_dest $dir
    err_chk $? "fuction : check"
    compare $vol_src $vol_dest $dir
    err_chk $? "fuction : compare"
  done
}

########################################
# Test
########################################

#check   /data2 /data5 test_dir
#err_chk $? "check"
#compare /data2 /data5 test_dir
#err_chk $? "compare"
#exit

########################################
# Main
########################################

#---------------------------------------
# Initailization
#---------------------------------------

rm -f $logpath

if [ ! -e $logpath ]; then
  touch $logpath
fi

echo "Start from $(date +"%Y/%m/%d %H:%M:%S")" | tee -a $logpath

#---------------------------------------
# Check
#---------------------------------------

# /data2 -> /data5
process /data2 /data5
err_chk $? "fuction : process"

