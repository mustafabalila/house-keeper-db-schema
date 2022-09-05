#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]; do
	key="$1"

	case $key in
	-f | --fix)
		FIX=true
		shift # past argument
		;;
	-h | --help)
		HELP=true
		shift # past argument
		;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift              # past argument
        ;;
	esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ ${HELP} == 'true' ]] || [[ ! -z $1 ]] || [[ $1 == 'help' ]]; then
    printf "Lints all files inside all directories (except init-db)\n\n"
	printf "Usage:\n\t[OPTIONS]\n"
    printf "Options:\n"
    printf "\t-f, --fix                   Forcefully fixes lint errors\n"
    printf "\t-h, --help                  Display this help menu\n"
    exit 0
fi

if [[ ! -x "$(command -v sqlfluff)" ]]; then
	printf "[Error] SQLFluff is not installed.\n"
	exit 1
fi

THREADS=1
if [[ ! -z "$CONCURRENCY" ]]; then
    THREADS=$CONCURRENCY
fi

printf "Running with ${THREADS} threads\n"

DIRECTORIES="$(ls -Iinit-db)"

if [[ ${FIX} == 'true' ]]; then
    printf "Fixing errors in all directories...\n"
    sqlfluff fix --processes ${THREADS} --exclude-rules L029 --force --ignore parsing --dialect postgres ${DIRECTORIES}
    exit 0
else
    printf "Linting all directories...\n"
    sqlfluff lint --processes ${THREADS} --exclude-rules L029 --ignore parsing --dialect postgres ${DIRECTORIES}
fi
