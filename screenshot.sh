#!/bin/bash


# the file that we create to know whether we've installed or not
INSTALL_FILE='./INSTALLED'
CONFIG_FILE='./config.ini'


if [ ! -f "$INSTALL_FILE" ]; then
  echo 'Please wait while we install everything...'

  sudo apt update
  sudo apt upgrade -y curl xclip
  
  # make sure to create the install file
  touch "$INSTALL_FILE"

  echo 'Successfully installed curl and xclip'
fi

# load the config.ini file
if [ ! -f "$CONFIG_FILE" ]; then
  cp 'default.ini' "$CONFIG_FILE"
fi

# load the values from the ini file
source <(grep = "$CONFIG_FILE")

# make sure the upload key isn't empty
if [ -z "$UPLOAD_KEY" -o "$UPLOAD_KEY" == ' ' ]; then
  echo "Please enter your upload key in $CONFIG_FILE"
  exit
fi

TEMP_FILE='temp.png'
gnome-screenshot -af "$TEMP_FILE"

# if the screenshot isn't saved then don't upload it
if [ ! -f "$TEMP_FILE" ]; then exit; fi

curl -s -X 'POST' -A 'Mozilla/5.0' \
     -H "Authorization: $UPLOAD_KEY" \
     -H 'Content-Type: multipart/form-data' \
     -F "file=@$TEMP_FILE" \
     -- "https://$DOMAIN/api/upload" | xclip -sel clip 2>/dev/null 1>&2

# it's temporary for a reason
rm "$TEMP_FILE"
