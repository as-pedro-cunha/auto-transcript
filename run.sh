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

source "$PATH_SCRIPT/tools/aux_functions.sh"

CONFIG="$PATH_SCRIPT/config/config.xml"

get_config_variables

# remove all files from output folder
#rm -rf "$output_path"/*

LOG_FILE="$PATH_SCRIPT/logs/$(date +%Y_%m_%d).txt"

# 
# remove all spaces from folders in folder_event and replace dashes with i
for folder_person in "$input_path"/*; do
    for folder_event_to_correct in "$folder_person"/*; do
        new_folder_name="$(basename "$folder_event_to_correct") | tr ' ' '_' | tr '-' '_' | tr '.' ''"
        # make double __ or triple __ to single _
        # replace folder name
        mv "$folder_event_to_correct" "$folder_person/$new_folder_name" 2>/dev/null
    done
done

# get all the events already processed (in the output folder)
events_processed=()
for folder_person_processed in "$output_path"/*; do
    for folder_event_processed in "$folder_person_processed"/*; do
        # get only the name of the folder
        events_processed+=($(basename "$folder_event_processed"))
    done
done

echo "---------------------------------------------------------------------------------------------------------"
for folder_person in "$input_path"/*; do
    PERSON="$(basename "$folder_person")"

    echo "Start processing folders for $PERSON:"
    echo "---------------------------------------------------------------------------------------------------------" >> $LOG_FILE
    echo "Start processing folders for $PERSON:" >> $LOG_FILE

    for folder_event in "$folder_person"/*; do
        # start counting time for each event
        START_TIME_EVENT=$(date +%s)

        EVENT="$(basename "$folder_event")"

        # check if event was already processed
        if [[ " ${events_processed[@]} " =~ " ${EVENT} " ]]; then
            echo "Event $EVENT was already processed, skipping..."
            continue
        fi

        echo "--------------------------------------------------------------------"
        echo "Processing event: $EVENT"
        echo "---------------------------"

        # from EVENT get the date (EVENT is in the format yyyy_mm_dd*)
        DATE="${EVENT:0:4}-${EVENT:5:2}-${EVENT:8:2}"

        # check if date contains exactly 8 numbers, if not exit 
        if [[ ! $DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            echo "Date is not in the correct format: $DATE"
            #exit 1
        fi

        # get YEAR, MONTH and DAY from DATE
        YEAR="${DATE:0:4}"
        MONTH="${DATE:5:2}"
        DAY="${DATE:8:2}"

        for track in "$folder_event"/*.mp3; do
            ORIGINAL_TRACK=$(basename "$track")
            # convert ç to c, á to a, etc
            TRACK=$(echo "$ORIGINAL_TRACK" | iconv -f utf8 -t ascii//TRANSLIT)
            # remove all the characters that are not letters, numbers, spaces, dashes or underscores
            
            TRACK_NAME="${TRACK%.*}"
            
            # get the track number, it must be in the first 4 characters, but get only the numbers
            TRACK_NUMBER=$(echo "${TRACK_NAME:0:4}" | grep -o "[0-9]*")
            # remove from TRACK_NAME any numbers in the first 4 characters, but left the rest untouched
            TRACK_NAME=$(sed -e 's/^[0-9]*//' <<< "$TRACK_NAME")
            # remove any initial or final spaces
            TRACK_NAME=$(echo "$TRACK_NAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            
            TRACK_NAME=$(echo "$TRACK_NAME" | sed 's/[^a-zA-Z0-9 ]//g')
            # change the track name in the file to the format: TRACK_NUMBER - TRACK_NAME.mp3
            FILE_NAME="$TRACK_NUMBER - $TRACK_NAME.mp3"

            # create, if not exists, the same folder structure in the output folder
            mkdir -p "$output_path/$PERSON/$EVENT"
            # copy the file to the output folder
            new_track="$output_path/$PERSON/$EVENT/$FILE_NAME"
            echo $new_track
            # convert the file to mp3 320kbps
            ffmpeg -y -i "$track" -ab 320k -hide_banner -loglevel error "$new_track" > null

            #transcription=$(python3 "$PATH_SCRIPT/tools/whisper_fun.py" "$track")
            python3 "$PATH_SCRIPT/tools/whisper_fun.py" "$new_track"

            # read .txt file with transcription
            txt_file="${new_track%.*}.txt"
            transcription=$(cat "$txt_file")

            # convert old id3v1 tag to id3v2
            id3v2 -s "$new_track" > null

            # create id3v2 tag on track (artist, album, year, track, title, comments = transcription)
            id3v2 -a "$PERSON" -A "$EVENT" -y "$YEAR" -T "$TRACK_NUMBER" -t "$TRACK_NAME" -c "$transcription" "$new_track" > null

            # show how many files are left to process
            # total mp3 files
            total_files=$(find "$folder_event" -type f -name "*.mp3" | wc -l)
            # total files already processed
            total_files_processed=$(find "$output_path/$PERSON/$EVENT" -type f -name "*.mp3" | wc -l)
            # total files left to process
            total_files_left=$((total_files - total_files_processed))
            # show how many files are left to process / total files
            echo "Files left to process: $total_files_left / $total_files"

        done
        # get the total length of the event in seconds
        total_length=$(find "$output_path/$PERSON/$EVENT" -type f -name "*.mp3" -exec ffprobe -i {} -show_entries format=duration -v quiet -of csv="p=0" \; | awk '{s+=$1} END {print s}')
        # get the total time to process the event
        END_TIME_EVENT=$(date +%s)
        DIFF_TIME_EVENT=$((END_TIME_EVENT - START_TIME_EVENT))
        average_speed=$((total_length / DIFF_TIME_EVENT))
        # show the total time to process the event
        echo "------------------------------------------------------------------------" >> $LOG_FILE 
        echo "$EVENT" >> $LOG_FILE
        # convert start time to human readable format
        echo "Event started processing at: $(date -d @$START_TIME_EVENT)" >> $LOG_FILE
        echo "Event end processing at: $(date -d @$END_TIME_EVENT):" >> $LOG_FILE 
        echo "was processed in:$DIFF_TIME_EVENT seconds" >> $LOG_FILE 
        echo "Total length of event: $total_length seconds" >> $LOG_FILE 
        echo "Average speed of processing: $average_speed seconds processed per second" >> $LOG_FILE 
        echo "------------------------------------------------------------------------" >> $LOG_FILE 
    done
done

# get the total lenght of all the files in the output folder
total_lenght=$(find "$output_path" -name "*.mp3" -exec ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 {} \; | awk '{ total += $1 } END { print total }')

# delete the file named null
rm 'null'

END_TIME=$(date +%s)

# calculate the total time of the script
TOTAL_TIME=$((END_TIME-START_TIME))
average_speed=$((total_length / TOTAL_TIME))

echo "------------------------------------------------------------------------" >> $LOG_FILE
echo "The processing took:" >> $LOG_FILE
echo "Total time: $TOTAL_TIME seconds" >> $LOG_FILE
echo "Total lenght: $total_lenght seconds" >> $LOG_FILE
echo "Average speed: $average_speed seconds processed per second" >> $LOG_FILE
echo "------------------------------------------------------------------------" >> $LOG_FILE

# run gather_txt.sh
bash "$PATH_SCRIPT/tools/gather_txt.sh"