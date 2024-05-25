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

# load config.xml
get_config_variables(){
    # get params in beetween <general_params> and </general_params>
    general_params="$(sed -n "/<general_params>/,/<\/general_params>/p" "$CONFIG" | sed '1d;$d')"
    # get in general_params the value of the variable input_path=
    input_path=$(echo "$general_params" | grep -m 1 "input_path=" | cut -d "=" -f 2)
    # get in general_params the value of the variable output_path=
    output_path=$(echo "$general_params" | grep -m 1 "output_path=" | cut -d "=" -f 2)
}
