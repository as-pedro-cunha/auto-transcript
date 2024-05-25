#!/bin/bash
########################################################################################################################
# Summary description may be here.
#
# Description:
#
#    Detailed description may be here.
#
# Author(s): Pedro Cunha
#
# Copyright TBD
########################################################################################################################

# count the start time of the script
START_TIME=$(date +%s)

# Ensure location
PATH_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "$PATH_SCRIPT" || { echo -e "Unreacheable script location: $PATH_SCRIPT \n exiting $0"; exit 1; }

CONFIG="$PATH_SCRIPT/../config/config.xml"

source "$PATH_SCRIPT/aux_functions.sh"

# Load enviroment variables
get_config_variables

# save all txt files to a folder with the same structure
cd $output_path
find . -name '*.txt' | cpio -pdm "$output_path/../transcricoes" >/dev/null 2>&1
cd $PATH_SCRIPT

# add the filename into each txt in $output_path/person/event folder
# but make it the first line of the file
for folder_person in "$output_path"/*; do
    transcricoes_completas="$output_path/../transcricoes/$(basename "$folder_person")/01_Transcricoes_Completas"
    # create transcricoes_completas folder if it does not exist
    mkdir -p "$transcricoes_completas"

    for folder_event in "$folder_person"/*; do

        txt_event="$folder_event/$(basename "$folder_event").txt"
        # remove the file if it already exists
        rm -f "$txt_event"

        # in the frist line of the txt_event file fill the following:
        echo "Transcrevido por: IA" >> "$txt_event"
        echo "Data transcrição: $(date +%d-%m-%Y)" >> "$txt_event"
        echo "Revisado por:" >> "$txt_event"
        echo "Núcleo revisor:" >> "$txt_event"
        echo "Data revisão:" >> "$txt_event"

        for txt_file in "$folder_event"/*.txt; do
            if [[ "$txt_file" == "$txt_event" ]]; then
                continue
            fi
            echo "" >> "$txt_event"
            echo "" >> "$txt_event"
            characters_per_line=100
            filename_wo_extension=$(basename "$txt_file" .txt)
            lenght_filename=$(echo "$filename_wo_extension" | wc -c)
            # the number of dashes on each side will be equal to 25 minus the number of characters in the filename
            lenght_dashes=$(echo "(($characters_per_line - $lenght_filename))/2" | bc)
            # create the variable that repeat the symbol - $lenght_dashes times
            dashes=$(printf '%*s' "$lenght_dashes" | tr ' ' '-')
            echo "$dashes   "$filename_wo_extension"   $dashes" >> "$txt_event"
            echo "" >> "$txt_event"
            # add the content of the .txt file
            cat "$txt_file" >> "$txt_event"
            # add a new line
            echo "" >> "$txt_event"
            
        done
        mv "$txt_event" "$transcricoes_completas/$(basename "$folder_event").txt"
    done
done