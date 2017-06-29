#!/bin/bash

# Process a given message file and return it to the user

#function usage

FILE_NAME_TO_READ=$1
FILE_NAME_TO_WRITE=.filter
SEARCH_STRING='root'
echo "echo somethings, $FILE_NAME_TO_READ, $FILE_NAME_TO_WRITE"

for OUTPUT in `cat ~/scripts/search_file | grep -iv '#'  `
do
    SEARCH_STRING=$OUTPUT'\|'$SEARCH_STRING
done

echo $SEARCH_STRING

grep $SEARCH_STRING $FILE_NAME_TO_READ
# > messages.fail.4.filte
