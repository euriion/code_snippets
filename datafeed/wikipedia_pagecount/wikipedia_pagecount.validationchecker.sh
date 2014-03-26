#!/bin/bash

FILE=$1
DELIMITER=$2
awk -F'$DELIMITER' '{if(NF!=6){print $0;}}' $FILE