#!/bin/sh

for item in $(ls $1)
do
  du $1/$item -s
done
