#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
HOME_DIR=`dirname ${SCRIPT_DIR}`


TotalCnt=5
FailCnt=0
FailCnt_d=0

echo "- Tests without options"

# tests with no option
for i in `seq 1 $TotalCnt`; do
	# without options
	diff <(${HOME_DIR}/bin/tse < ${HOME_DIR}/tests/input/${i}.sql) ${HOME_DIR}/tests/expected/${i}.out > /dev/null 2>&1
	case $? in
		0 ) echo "  case ${i} ... success" ;;
		1 ) echo "  case ${i} ... fail"
			FailCnt=`expr $FailCnt + 1`
			;;
	esac
done

echo "- Tests with -d option"

# tests with -d option
for i in `seq 1 $TotalCnt`; do
	# without options
	diff <(${HOME_DIR}/bin/tse -d < ${HOME_DIR}/tests/input/${i}.sql) ${HOME_DIR}/tests/expected/${i}d.out > /dev/null 2>&1
	case $? in
		0 ) echo "  case ${i} ... success" ;;
		1 ) echo "  case ${i} ... fail"
			FailCnt_d=`expr $FailCnt_d + 1`
			;;
	esac
done


echo "-- Summary --"

# summary of tests with no option
if [ $FailCnt -eq 0 ]; then 
	echo "[success] Passed all tests with no options"
else
	echo "[Fail] ${FailCnt}/${TotalCnt} tests with no options."
fi

# summary of tests with -d option
if [ $FailCnt_d -eq 0 ]; then 
	echo "[success] Passed all tests with option -d"
else
	echo "[Fail] ${FailCnt_d}/${TotalCnt} tests with option -d."
fi


