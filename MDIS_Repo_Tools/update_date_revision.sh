#! /bin/bash

# THIS SCRIPT MUST BE RUN FROM 13MD05-90 REPOSITORY

get_ynq_answer() {
        while true
        do
                echo -e -n $1 '(y/n/q): '
                read answer
                case ${answer} in
                [Yy]) return 0;;
                [Nn]) return 1;;
                [Qq]) return 2;;
                esac
        done
}

make_commit() {
git pull origin jpe-dev
git checkout jpe-dev
git add *.xml
git commit -m "xml file update

Add valid revision format"
git log -n2
#commit into remote
git push origin jpe-dev
}

############################################################################
############################# MAIN START ###################################
############################################################################

readonly OverwriteQ="Overwrite?"

MDISDir=$(pwd)

#grep -r --include "*.xml" "<revision>.*<\/revision>"
#grep -r --include "*.xml" "<date>.*<\/date>"
Submodules_to_process_path=$(git submodule foreach --quiet  '[ "$(find . -name "*.xml")" ] && echo  $path || true')
while read -r submodule <&9; do
        echo "${MDISDir}/${submodule}"
        cd "${MDISDir}/${submodule}"
        GitRevision=$(git describe --dirty --long --tags --always)
        GitDate=$(git --no-pager show -s --date=short --format=format:"%cd%n")
        XmlFilesToProcess=$(find . -name "*.xml")

        GitRevisionOld=$(grep -r --include "*.xml" "<revision>")
        GitDateOld=$(grep -r --include "*.xml" "<date>")

        while read -r xmlFile <&8; do
            echo "xmlFile: ${xmlFile}"
            sed -i 's|'"<date>.*</date>"'|'"<date>${GitDate}</date>"'|g' ${xmlFile}
            sed -i 's|'"<revision>.*</revision>"'|'"<revision>${GitRevision}</revision>"'|g' ${xmlFile}
        done 8<<< "${XmlFilesToProcess}"

        GitRevisionNew=$(grep -r --include "*.xml" "<revision>")
        GitDateNew=$(grep -r --include "*.xml" "<date>")

        echo "-----old-----------"
        echo "${GitDateOld}"
        echo "${GitRevisionOld}"
        echo "-----new-----------"
        echo "${GitDateNew}"
        echo "${GitRevisionNew}"
        echo "-----end-----------"

        get_ynq_answer "${OverwriteQ}" 
        case $? in
                0 )     make_commit
                        ;;
             1 | 2)     echo "Do not commit the changes"
                        git reset --hard
                        ;;
        esac

        cd ${MDISDir}
done 9<<< "${Submodules_to_process_path}"

