#!/bin/bash
RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"
echo -e "${GREEN}This script make restore files and database.${RESET}"
#sleep 1s
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
    SOURCE="$DIR/$TARGET"
  fi
done
echo "SOURCE is '$SOURCE'"
RDIR="$( dirname "$SOURCE" )"
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

if [ "$DIR" != "$RDIR" ]; then
  echo -e "${GREEN}DIR $RDIR resolves to $DIR ${RESET}"
fi
sudo mysql -u root -p project_db_name < $DIR/backup/project_db_name.sql
sudo unzip -o $DIR/backup/project_backup.zip -d $DIR/web/upload
echo -e "${GREEN}Process started. Files well be overwriten and database is restored...${RESET}"


