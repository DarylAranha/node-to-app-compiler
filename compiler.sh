#! /bin/sh

TEMP_DIR="/tmp"
CURRENT_DIR=${PWD}

FOLDER_NAME="package-compiler"
PACKAGE_FILE="nodePackage.js"
COMPILED_FILE="convertedPackage.js"
PACKAGE_TO_INSTALL=$1
IS_LOCAL="false"

# Perform operation in tmp folder
cd $TEMP_DIR && mkdir -p $FOLDER_NAME && cd $FOLDER_NAME

# check if option is provided
# Note: only option available to now is --help and --local
# by default, the package will be downloaded via npm, if --local is provided then
# the script will use the in-build package
if [ -z "$1" ]; then
    echo -e "Command: \n\t <options> <node_package>"
    exit
fi

PACKAGE_TO_INSTALL=$1

if [ "$1" = "--help" ]; then
    echo -e "Command: \n\t <options> <node_package>"
    echo -e "Options: \n\t --local Search node in-built package. By default, the script will install the package"
    exit
fi

if [ "$1" = "--local" ]; then
    if [ ! -z "$2" ]; then
        IS_LOCAL="true"
        PACKAGE_TO_INSTALL=$2
    else
        echo -e "Command: \n\t <options> <node_package>"
        exit
    fi
fi

if [ "$IS_LOCAL" == "false" ]; then
    npm install $PACKAGE_TO_INSTALL
fi

PACKAGE_NAME=$(echo $PACKAGE_TO_INSTALL | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
VARIABLE_NAME="${PACKAGE_NAME}Compiled"
COMPRESSED_COMPILED_FILE="${PACKAGE_NAME}CompiledPackage.js"

# generate a file that import the package
echo -e "let $VARIABLE_NAME = require('$PACKAGE_TO_INSTALL');\nmodule.exports = $VARIABLE_NAME;" > $PACKAGE_FILE

# generate the compiled file
node node_modules/browserify/bin/cmd.js $PACKAGE_FILE -o $COMPILED_FILE

# open the file and do the following
# 1. create a global variable
# 2. replace local import of package to variable to global
# 3. replace all existance of require
# 4. export the global variable
sed -i "s/let $VARIABLE_NAME = require('$PACKAGE_TO_INSTALL');/$VARIABLE_NAME = require('$PACKAGE_TO_INSTALL');/g" $COMPILED_FILE
sed -i "s/module.exports = $VARIABLE_NAME;//g" $COMPILED_FILE
sed -i 's/require/fetchPackage/g' $COMPILED_FILE
echo -e "var $VARIABLE_NAME;\nmodule.exports = $VARIABLE_NAME;" >> $COMPILED_FILE

# Compress the file
node node_modules/uglify-js/bin/uglifyjs  $COMPILED_FILE -c -o $COMPRESSED_COMPILED_FILE

# move the computer result back to app folder
cp $COMPRESSED_COMPILED_FILE $CURRENT_DIR

echo -e "Completed.\nUsage: import $VARIABLE_NAME from './$COMPRESSED_COMPILED_FILE';"
