#!/bin/bash

#######################################
### CREATED BY RAFAEL RITTMEYER     ###
### LAST MODIFICATION 02/05/23      ###
#######################################

## VARIABLES LIST ##

OLD_IFS=$IFS
CSV_FILE="$1"
DST_PATH="/tmp/Exten"

HELP_MSG="Usage: $0 </path/to/source.csv>

Brief:
    This script was made to make the exten configuration easier. 
    To do that, we use a CSV file, following the structure bellow, to build the SQL files.
    Those SQL file shold be imported (source command) on MySQL's client.

CSV Structure:
    * Exten (Only Number)
    * Name
    * Sector

CSV file separator:
    Semicolon (;)

Options:
    --help|-h   Show this help message
"

FINAL_MSG="All done. =) 

Final instructions:
    Go to the directory $DST_PATH.
    Invoke MySQL and use the source command to import the EXTEN configuration
"

## CODE ZONE ##

function main () {

    ### Help Section
    if [ "$1" = '-h' ] || [ "$1" = "--help" ]; then
        printf "%s\n" "${HELP_MSG}"
        return 0
    
    elif [ -z "$1" ]; then
        printf "%s\n" "${HELP_MSG}"
        return 0

    fi

    buildTeams "$1"

}

function buildTeams() {

    ### Structure
    rm -rf $DST_PATH
    mkdir -p $DST_PATH

    ### Build SQL file
    IFS=';'
    while read -r EXTEN NAME SECTOR; do

        printf "update trex_ramais set no_titulo=\"%s\" where id_ramal=\"%s\";\n" "$NAME" "$EXTEN" >> $DST_PATH/no_titulo.sql
        printf "update trex_ramais set no_setor=\"%s\" where id_ramal=\"%s\";\n" "$SECTOR" "$EXTEN" >> $DST_PATH/no_setor.sql

    done < "$CSV_FILE"

        printf "%s" "${FINAL_MSG}"

    IFS=$OLD_IFS
}

main "$1"
