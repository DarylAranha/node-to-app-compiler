#! /bin/sh

TEMP_DIR="/tmp"
CURRENT_DIR=${PWD}

FOLDER_NAME="package-compiler"
PACKAGE_FILE="nodePackage.js"
COMPILED_FILE="convertedPackage.js"
COMPRESSED_COMPILED_FILE="compiledPackage.js"

cd $TEMP_DIR && mkdir -p $FOLDER_NAME && cd $FOLDER_NAME

npm install browserify

npm install uglify-js

npm install $1

# generate a file that import the package
echo -e "let requestedPackage = require('$1');\nmodule.exports = requestedPackage;" > $PACKAGE_FILE

# generate the compiled file
node node_modules/browserify/bin/cmd.js $PACKAGE_FILE -o $COMPILED_FILE

# open the file and do the following
# 1. create a global variable
# 2. replace local import of package to variable to global
# 3. replace all existance of require
# 4. export the global variable
sed -i "s/let requestedPackage = require('$1');/requestedPackage = require('$1');/g" $COMPILED_FILE
sed -i "s/module.exports = requestedPackage;//g" $COMPILED_FILE
sed -i 's/require/fetchPackage/g' $COMPILED_FILE
echo -e "var requestedPackage;\nmodule.exports = requestedPackage;" >> $COMPILED_FILE

# Compress the file
node node_modules/uglify-js/bin/uglifyjs  $COMPILED_FILE -c -o $COMPRESSED_COMPILED_FILE

cp $COMPRESSED_COMPILED_FILE $CURRENT_DIR
