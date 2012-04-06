#!/bin/bash
#
# MongoDB Restore Script
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

#Validate object before inserting
OBJCHECK="true"

# Command to run before backups (uncomment to use)
# PREBACKUP=""

# Command run after backups (uncomment to use)
# POSTBACKUP=""

# Do we need to use a username/password?
if [ "$DBUSERNAME" ]
  then
  OPT="$OPT --username=$DBUSERNAME --password=$DBPASSWORD"
fi

if [ "$COLLECTIONNAME" ]
  then
  OPT="$OPT --collection=$COLLECTIONNAME --db=$DBNAME"
fi

if [ "$DROPCOLLECTION" == "true" ]
	then
	OPT="$OPT --drop"
fi

if [ "$OBJCHECK" == "true" ]
   then
  OPT="$OPT --objcheck"
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

	mongorestore --host=$DBHOST:$DBPORT $OPT ${1}
	
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
echo AutoMongoRestore VER $VER
echo
echo Restore of Database ${DBNAME} into collection ${COLLECTIONNAME} - $HOST on $DBHOST
echo ======================================================================

echo Restore Start `date`
echo ======================================================================


import $1
echo Restore End Time `date`
echo ======================================================================
