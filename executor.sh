#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -d | --database)
        DATABASE="$2"
        shift # past argument
        shift # past value
        ;;
    -h | --help)
        HELP=true
        shift # past argument
        ;;
    -i | --init)
        INIT=true
        shift # past argument
        ;;
    --init-only)
        INIT_ONLY=true
        shift # past argument
        ;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift              # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ ${HELP} == 'true' ]] || [[ -z $1 ]] || [[ $1 == 'help' ]]; then
    printf "Usage:\n\t[COMMAND] -d DATABASE_NAME [OPTIONS]\n"
    printf "Commands:\n"
    printf "\thelp                        Display this help menu\n"
    printf "\tinfo                        Returns information regarding the current database state\n"
    printf "\tmigrate                     Execute the database migrations\n"
    printf "\tclean                       Cleans up the database by dropping all objects (DO NOT USE IN PRODUCTION)\n"
    printf "Options:\n"
    printf "\t-h, --help                  Display this help menu\n"
    printf "\t-d NAME, --database NAME    The name of the database being managed\n"
    printf "\t-i, --init                  Include the 'init-db' migrations in the evaluation\n"
    printf "\t--init-only                 Only evaluate the 'init-db' migrations\n"
    printf "Examples:\n"
    printf "\tInspect the current status of the database:\n"
    printf "\tinfo -d DATABASE_NAME\n\n"
    printf "\tInitialize a new database without executing all migrations:\n"
    printf "\tmigrate -d DATABASE_NAME --init-only\n\n"
    printf "\tInitialize a new database and execute all migrations:\n"
    printf "\tmigrate -d DATABASE_NAME --init\n\n"
    printf "\tExecute migrations on an existing database:\n"
    printf "\tmigrate -d DATABASE_NAME\n\n"
    exit 0
fi

if [[ $1 != 'info' ]] && [[ $1 != 'migrate' ]] && [[ $1 != 'clean' ]]; then
    printf "[Error] Invalid command: $1\n"
    exit 1
fi

if [[ -z ${DATABASE} ]]; then
    printf "[Error] Missing database argument.\n"
    printf "\tExample usage: migrate -d DATABASE_NAME [OPTIONS] [COMMAND]\n"
    exit 1
fi

if [[ ! -d ${DATABASE} ]]; then
    printf "[Error] Invalid database: ${DATABASE}. Directory not found.\n"
    exit 1
fi

if [[ ! -e ${DATABASE}/flyway.conf ]]; then
    printf "[Error] Missing flyway.conf configuration file.\n"
    exit 1
fi

printf "Selected database: ${DATABASE}\n"
INIT_DB_CONFIG_FILES="./init-db/flyway.conf"
MAIN_DB_CONFIG_FIlES="./${DATABASE}/flyway.conf"

if [[ $1 == 'info' ]]; then
    printf "Public schema status:\n"
    flyway -configFiles=${INIT_DB_CONFIG_FILES} info
    printf "Main schema status:\n"
    flyway -configFiles=${MAIN_DB_CONFIG_FIlES} info
elif [[ $1 == 'migrate' ]]; then
    printf "Executing migrations...\n"

    if [[ ${INIT} == 'true' ]] || [[ ${INIT_ONLY} == 'true' ]]; then
        printf "[INIT] initializing new database...\n"
        flyway -configFiles=${INIT_DB_CONFIG_FILES} migrate
        printf "[INIT] finished initializing new database.\n"
        if [[ ${INIT_ONLY} == 'true' ]]; then
            exit 0
        fi
    fi

    printf "Executing ${DATABASE} migrations...\n"
    flyway -configFiles=${MAIN_DB_CONFIG_FIlES} migrate
    printf "Finished executing ${DATABASE} migrations.\n"
elif [[ $1 == 'clean' ]]; then
    printf "You are about to drop all objects defined in the ${DATABASE} database.\n"
    read -p "Are you sure? [y/N] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        printf "Cleaning up ${DATABASE} database...\n"
        flyway -configFiles=${MAIN_DB_CONFIG_FIlES} clean
        printf "Finished cleaning up ${DATABASE} database.\n"
    else
        printf "No modifications were made to ${DATABASE} database.\n"
    fi
fi
