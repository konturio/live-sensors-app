#!/bin/bash

# read latest versions
version=$(git tag | grep -E '^[0-9]' | sort -V | tail -1)
echo "Current version is: $version"
echo "Increase major/minor/path? (M/m/p):"
read answer

if [[ $answer == "M" || $answer == "m" || $answer == "p" ]];
then
    new_version=$(/bin/bash ./scripts/increment_version.sh -${answer} ${version})
    echo "New version will be $new_version"
    echo -e "\033[5mContinue?\033[0m (y/n):"
    read confirmation
    if [[ $confirmation == y* ]];
    then
        
        ver_line=$(grep -n 'version:' pubspec.yaml | cut -d ':' -f1)
        sed -i "${ver_line}s/.*/version: ${new_version}/" pubspec.yaml
        git add pubspec.yaml
        git commit -m $new_version
        git tag $new_version
        git push --tags
        echo "Release created successfully"
        echo "Run build.sh script for deploy"
    else
        echo "Mission failed succesfully"
    fi
else
    echo "Canceled"
fi