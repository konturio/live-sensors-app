#!/bin/bash
/bin/bash ./scripts/ask_and_set_version.sh
/bin/bash ./scripts/build.sh
echo
read -p "Release new version? (y/n): " -n 1 -r choice
echo
case "$choice" in 
  y|Y ) /bin/bash ./scripts/upload.sh;;
  n|N ) echo "Uploading canceled.";;
  * ) echo "invalid answer";;
esac
