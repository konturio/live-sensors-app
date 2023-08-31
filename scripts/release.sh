#!/bin/bash
/bin/bash ./ask_and_set_version.sh
/bin/bash ./build.sh
echo
read -p "Release new version? (y/n): " -n 1 -r choice
echo
case "$choice" in 
  y|Y ) git push --tags;;
  n|N ) echo "Uploading canceled.";;
  * ) echo "invalid answer";;
esac
