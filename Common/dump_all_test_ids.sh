#!/bin/bash

if [ ! -f "Conf.sh" ]; then
    echo ">> Error. Unable to find Conf.sh file. Please run the script within Common/ folder"
    exit 1
fi

source "Conf.sh"

function dump_setup_test_cases {
	setup=$1
	declare -n map="$2"

	create_test_setup_test_cases_map $setup

	echo ">> ***** Test setup $setup. TEST IDs ******"
	for i in "${!map[@]}"
	do
		  echo ">> $i: (${TEST_CASES_MAP[$i]}) [${map[$i]}]"
	done
	echo ">> ***********************************"
}

### MAIN ENTRY POINT ###

get_test_cases_map "../Target/"

echo ">> *********** AL TEST IDs ***********"
for i in "${!TEST_CASES_MAP[@]}"
do
  echo ">> $i: ${TEST_CASES_MAP[$i]}"
done
echo ">> ***********************************"

echo ""

for setup in {1..11}
do
	testSetup="TEST_SETUP_"$setup"_TEST_CASES"
    echo ""
	echo ">> $testSetup"
	testSetupTestCases="testSetup"

	dump_setup_test_cases $setup ${!testSetupTestCases}
done