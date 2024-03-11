#!/usr/bin/bash

# if first arg to this script wasn't given, then exit
if [ -z "$1" ]; then
    echo "Usage: $0 <newname>"
    exit 1
fi


grep -rl "MyAddOn" *.{lua,xml} | xargs sed -i "s/MyAddOn/$1/g"
 
 

 
