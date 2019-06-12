#! /bin/bash

################
# Copyright <year_of_file_creation>-<year_of_last_file_change>, MEN Mikro Elektronik GmbH
################
MenCopyrightBegin="Copyright (c) "
MenCopyrightEnd=", MEN Mikro Elektronik GmbH"

CopyrighCurrentYear="2019"

function add_men_copyright () {
local FileName=${1}

# Case 1 - Copyright(c) 1998, MEN Mikro Elektronik GmbH
# Case 2 - Copyright(c) 1998-2013, MEN Mikro Elektronik GmbH

# Extract Date of file original MEN copyrights, first date that should be used in the whole file
local YearOfCreation=$(cat "${FileName}" | grep -i 'Copyright (c) ' | grep -P -o -e ' [0-9]{4}' | sed 's/\ //g' | head -1)

#if [ "${YearOfCreation}" != "${CopyrighCurrentYear}" ]
#then
        sed -i -e 's/Copyright (c).*, MEN Mikro Elektronik GmbH/'"${MenCopyrightBegin}${YearOfCreation}-${CopyrighCurrentYear}${MenCopyrightEnd}"'/g' ${FileName}
#fi
}

############################################################################
############################# MAIN START ###################################
############################################################################

# Save list of affected files: all c and h files
FilesToProcess=$(find . -type f \( -name "*.c" -or -name "*.h" -or -name "*.mak" \) -exec grep -iRl "Copyright.*, MEN Mikro Elektronik GmbH" {} \;)
FilesToProcessCnt=0

while read singleFile; do
        echo "Processing file: ${singleFile}"
        add_men_copyright "${singleFile}"
        FilesToProcessCnt=$((${FilesToProcessCnt}+1))
done <<<${FilesToProcess}

echo "Processed files: ${FilesToProcessCnt}"
