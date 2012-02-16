#!/bin/bash
#
# MongoDB Import Script
# VER. 0.1
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#=====================================================================
#=====================================================================
# Set the following variables to your system needs
# (Detailed instructions below variables)
#=====================================================================

# External config - override default values set below
# EXTERNAL_CONFIG="/etc/default/automongobackup"	# debian style
EXTERNAL_CONFIG="/etc/sysconfig/automongobackup"	# centos style

# MongoDB version
MONGO_VERSION=`expr  "$(mongo --version)" : ".*version: \(.*\)"`

# Database name to backup a specific database
DBNAME="prod_declic"

# Collection name to backup a specific collection
COLLECTIONNAME="widgets"

# Username to access the mongo server e.g. dbuser
# Unnecessary if authentication is off
# DBUSERNAME=""

# Username to access the mongo server e.g. password
# Unnecessary if authentication is off
# DBPASSWORD=""

# Host name (or IP address) of mongo server e.g localhost
DBHOST="127.0.0.1"

# Port that mongo is listening on
DBPORT="27017"

# Drop collection first
DROPCOLLECTION="true"

# File to import from
FILE=""

# CSV,TSV only - use first line as headers
HEADERLINE="false"

# Type of file to import. Default: json (json,csv,tsv)
FILETYPE="json"

# If given, empty fields in csv and tsv will be ignored
IGNOREBLANK=""

# 1.5.3+ - Insert or update objects that already exist
UPSERT="false"

# 1.5.3+ - Stop importing at the first error rather than continuing
STOPONERROR="false"

# 1.5.3+ - Load a json array, not one item per line. Currently limited to 4MB.
JSONARRAY="false"

# Command to run before backups (uncomment to use)
# PREBACKUP=""

# Command run after backups (uncomment to use)
# POSTBACKUP=""

# Do we need to use a username/password?
if [ "$COLLECTIONNAME" ]
  then
  OPT="$OPT --collection=$COLLECTIONNAME --db=$DBNAME"
fi

if [ "$DROPCOLLECTION" == "true" ]
	then
	OPT="$OPT --drop"
fi

if [ "$HEADERLINE" == "true" ]
	then
	OPT="$OPT --headerline"
fi

if [ "$FILETYPE" ]
	then
	OPT="$OPT --type=$FILETYPE"
fi

if [ "$IGNOREBLANK" == "true" ]
	then
	OPT="$OPT --ignoreBlanks"
fi

if [ "$UPSERT" == "true" ]
	then

	if [[ ${MONGO_VERSION} > "1.5.3"  ]]
		then
		OPT="$OPT --upsert"
	else
		echo "Upsert option is only available in mongo 1.5.3+, your version is ${MONGO_VERSION}."
		exit 0
	fi
fi

if [ "$STOPONERROR" == "true" ]
	then

	if [[ ${MONGO_VERSION} > "1.5.3"  ]]
		then
		OPT="$OPT --stopOnError"
	else
		echo "StopOnError option is only available in mongo 1.5.3+, your version is ${MONGO_VERSION}."
		exit 0
	fi
fi

if [ "$JSONARRAY" == "true" ]
	then

	if [[ ${MONGO_VERSION} > "1.5.3"  ]]
		then
		OPT="$OPT --jsonArray"
	else
		echo "JsonArray option is only available in mongo 1.5.3+, your version is ${MONGO_VERSION}."
		exit 0
	fi
fi

# Include external config
[ ! -z "$EXTERNAL_CONFIG" ] && [ -f "$EXTERNAL_CONFIG" ] && source "${EXTERNAL_CONFIG}"
# Include extra config file if specified on commandline, e.g. for backuping several remote dbs from central server
[ ! -z "$1" ] && [ -f "$1" ] && source ${1}

VER=0.1

function import () {
	
	if [ ! -e ${1} ]
		then
		echo "File not exist."
		exit 0
	elif [ -z ${1} ]
		then
		echo "File ${1} is empty."
		exit 0
	fi

	echo mongoimport --host=$DBHOST:$DBPORT $OPT --file=${1} 
	mongoimport --host=$DBHOST:$DBPORT $OPT --file=${1}
	
	if [ $? -ne 0 ]
  		then
  		echo "ERROR: Error occured during import." >&2
  		return 1
  	fi
}

clear

if [ -z "$1" ]
	then
	echo "Usage: automongoimport my_import_file.json"
	echo "Please specify the file to import from."
	
	exit 0
fi

echo ======================================================================
echo AutoMongoImport VER $VER
echo
echo Import of Database ${DBNAME} into collection ${COLLECTIONNAME} - $HOST on $DBHOST
echo ======================================================================

echo Import Start `date`
echo ======================================================================


import $1
echo Import End Time `date`
echo ======================================================================