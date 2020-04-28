#! /bin/bash
### @brief create and push updated tags for all submodules in 13MD05-90 repository
###        increase minor revision +1  
### @remark This script should be run in 13MD05-90 git repository main directory


declare -r TAG_MSG="Tag created for MDIS release 13MD05-90_02_02"


function get_ynq_answer() {
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

function push_tag_into_repo() {
    local submoduleName="${1}"
    local submoduleMajorRev="${2}"
    local submoduleMinorRev="${3}"
    local tagCommit="${4}"
    get_ynq_answer "Create tag and push into repo?"
    case $? in
        0)
            echo "Pushing tag into repo"
            git tag -a  ${submoduleName}_${submoduleMajorRev}_${submoduleMinorRev} -m "${TAG_MSG}"
            git push origin --tags
            ;;
        1)
            echo "*** Skip submodule..."
            ;;
        2)
            echo "*** Abort..."
            exit 1;
            ;;
    esac
}

############################################################################
############################# MAIN START ###################################
############################################################################

submodulesPath=$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }')
submodulesName=$(git config --file .gitmodules --get-regexp url | awk '{ print $2}' | sed -e "s/..\///g" | sed -e "s/.git//g")
submoduleTotalNum=$(echo "${submodulesName}" | wc -l)

git submodule foreach 'git show-ref --tags || :' > submodule_tags_all.log

# Below commands reset tags to origin
# git submodule foreach 'git tag -l | xargs git tag -d'
# git fetch --tags
# Show current Commit ID
# git rev-parse HEAD

# loop through submodules
echo "current path: $PWD"
PROJECT_PATH=$PWD

for i in $(seq 1 ${submoduleTotalNum})
do
    echo "submodule ${i} of ${submoduleTotalNum}"
    submoduleName=$(echo "${submodulesName}" | awk NR==${i})
    submodulePath=$(echo "${submodulesPath}" | awk NR==${i})

    echo "submodule path: ${submodulePath}"
    echo "submodule name: ${submoduleName}"

    # move to submodule directory
    cd ${submodulePath}
    if [ $? -eq 0 ]
    then
        git checkout -- .
        git checkout master>/dev/null
        if [ $? -eq 0 ]
        then
            # create tag ..."
            # obtain the last commit name, and increment the minor_rev
            currentTag=$(git describe --tag --abbrev=0)
            if [ ! -z "${currentTag}" ]
            then
                echo "current tag: ${currentTag} found"
                tagCommitPrevious=$(cat ${PROJECT_PATH}/submodule_tags_all.log | grep "${currentTag}" | awk '{print $1}')
                submoduleMajorRev=$(git describe --tag --abbrev=0 | sed -e "s|${submoduleName}_||g" | head -c 2)
                submoduleMinorRev=$(git describe --tag --abbrev=0 | sed -e "s|${submoduleName}_||g" | tail -c 3)
                submoduleMinorRev=$(expr ${submoduleMinorRev} + 1)
                submoduleMinorRev=$(printf "%02d" ${submoduleMinorRev})
                tagCommit="$(git rev-parse HEAD)"
                echo "create tag:  ${submoduleName}_${submoduleMajorRev}_${submoduleMinorRev}"
                echo "tag will point into: ${tagCommit}"
                if [ "${tagCommitPrevious}" == "${tagCommit}" ]
                then
                    echo "TagCommitPrevious and TagCommit is the same, do nothing:"
                    echo "${tagCommitPrevious} : ${currentTag}"
                    echo "${tagCommit} : ${submoduleName}_${submoduleMajorRev}_${submoduleMinorRev}"
                else
                    push_tag_into_repo "${submoduleName}" "${submoduleMajorRev}" "${submoduleMinorRev}" "${tagCommit}" 
                    echo ""
                fi
            else
                echo "CurrentTag: ${currentTag} not found :-("
                # If no tag is specified create first tag <submodule_name>_1_00
                submoduleMajorRev="01"
                submoduleMinorRev="00"
                echo "create tag: ${submoduleName}_${submoduleMajorRev}_${submoduleMinorRev}"
                echo "${tagCommit} : ${submoduleName}_${submoduleMajorRev}_${submoduleMinorRev}"
                push_tag_into_repo "${submoduleName}" "${submoduleMajorRev}" "${submoduleMinorRev}" "${tagCommit}" 
                echo ""
            fi
        else
            echo "could not switch to master branch: ${submoduleName}"
        fi
        # move to directory when the script exists
        cd ${PROJECT_PATH}
        echo "path: ${PWD}"
    else
        echo "submodule not present: $i" 
    fi
done
