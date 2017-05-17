#!/bin/bash
projectname="project_name"
projectdbname="project_db_name"
dbpass="project_db_pass"
apachevhostname="project.local.conf"

RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"

function cblue(){
    echo -e "${BLUE}$1${RESET}"
}
function cgreen(){
    echo -e "${GREEN}$1${RESET}"
}
function cred(){
    echo -e "${RED}$1${RESET}"
}

cblue "This script make backup files and database."
SOURCE="${BASH_SOURCE[0]}"

while [ -h "$SOURCE" ]; do
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    cblue "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    cblue "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
    SOURCE="$DIR/$TARGET"
  fi
done

cblue "Script '$SOURCE'"

RDIR="$( dirname "$SOURCE" )"
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

if [ "$DIR" != "$RDIR" ]; then
  cgreen "DIR $RDIR resolves to $DIR "
fi
datenow="$(date +'%Y-%m-%d-%H-%M')"
backupname="${projectname}-"
backupdirname=${backupname}${datenow}
backupdirpath="${DIR}/backup/${backupdirname}"
cgreen "${backupdirpath}."

function makeBackup (){
    b1=$1
    sudo cp /etc/apache2/sites-available/$apachevhostname $b1/$3
    sudo chmod 0775 $b1/$3
    sudo chown server_user:server_group $b1/$3
    cgreen "--------------------------------------"
    cgreen "Apache vhost config ok $3 "
    cgreen "--------------------------------------"
    dbcommand="-h localhost -u root -p$5 $2 > $b1/$2.sql"
    dbaction=$( sudo mysqldump -h localhost -u root -p$5 $2 > $b1/$2.sql )
    cred "${dbaction}"
    cgreen "--------------------------------------"
    cgreen "Database $2.sql ok "
    cd web/upload
    zipaction=$( zip -rq $b1/upload.zip . )
    cred "${zipaction}"
    cgreen "--------------------------------------"
    cgreen "Upload directory ok "
    cd ../../src
    zip -rq $b1/src.zip .
    cgreen "--------------------------------------"
    cgreen "src directory ok "
    cd ../app
    zip -rq $b1/app.zip .
    cgreen "--------------------------------------"
    cgreen "app directory ok "
    cd ..
    zip $b1/composer.zip composer.* 
    zip -rq $b1/commands.zip *.sh
    cgreen "--------------------------------------"
    cgreen "Composer and commands ok "
    cgreen "--------------------------------------"
    cgreen "Backup created at: $(date +'%Y-%m-%d:%H:%M:%S')"
}

if [ ! -d "${backupdirpath}" ]; then
    mkdir -p "${backupdirpath}"
    if [ $? -ne 0 ]; then
        cred "Cannot create folder at ${backupdirpath}. Dying ..."
        exit 0
    else
        cgreen "--------------------------------------"
        cgreen "Successfully create ${backupdirpath}. "
        makeBackup $backupdirpath $projectdbname $apachevhostname $projectname $dbpass
    fi
else
        cgreen "--------------------------------------"
        cgreen "Directory exist ${backupdirpath}. "
        makeBackup $backupdirpath $projectdbname $apachevhostname $projectname $dbpass
fi

exit 0
