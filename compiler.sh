#! /bin/sh

TEMP_DIR="/tmp"
CURRENT_DIR=${PWD}

FOLDER_NAME="package-compiler"
PACKAGE_FILE="nodePackage.js"
COMPILED_FILE="convertedPackage.js"

PACKAGE_NAME=$(echo $1 | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')
VARIABLE_NAME="${PACKAGE_NAME}Compiled"
COMPRESSED_COMPILED_FILE="${PACKAGE_NAME}CompiledPackage.js"

# Perform operation in tmp folder
cd $TEMP_DIR && mkdir -p $FOLDER_NAME && cd $FOLDER_NAME

npm install browserify

npm install uglify-js

npm install $1

# generate a file that import the package
echo -e "let $VARIABLE_NAME = require('$1');\nmodule.exports = $VARIABLE_NAME;" > $PACKAGE_FILE

# generate the compiled file
node node_modules/browserify/bin/cmd.js $PACKAGE_FILE -o $COMPILED_FILE

# open the file and do the following
# 1. create a global variable
# 2. replace local import of package to variable to global
# 3. replace all existance of require
# 4. export the global variable
sed -i "s/let $VARIABLE_NAME = require('$1');/$VARIABLE_NAME = require('$1');/g" $COMPILED_FILE
sed -i "s/module.exports = $VARIABLE_NAME;//g" $COMPILED_FILE
sed -i 's/require/fetchPackage/g' $COMPILED_FILE
echo -e "var $VARIABLE_NAME;\nmodule.exports = $VARIABLE_NAME;" >> $COMPILED_FILE

# Compress the file
node node_modules/uglify-js/bin/uglifyjs  $COMPILED_FILE -c -o $COMPRESSED_COMPILED_FILE

# move the computer result back to app folder
cp $COMPRESSED_COMPILED_FILE $CURRENT_DIR
