#!/bin/sh

for item in $(ls $1)
do
  echo "$item $(find $1/$item -type f | wc -l)"
done
