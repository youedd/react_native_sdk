#!/usr/bin/env bash

# Exit if any errors occur
set -e

# Get the current directory (/scripts/ directory)
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Traverse up to get to the root directory
ROOT_DIR="$(dirname "$SCRIPTS_DIR")"
PROJECT_DIR=test/app
SDK_PLUGIN_NAME=react-native-adjust
TEST_PLUGIN_DIR=test/lib
SDK_PLUGIN_NAME=react-native-adjust
TEST_PLUGIN_NAME=react-native-adjust-testing

RED='\033[0;31m' # Red color
GREEN='\033[0;32m' # Green color
NC='\033[0m' # No Color

# Kill any previously running packager instances
# TODO: does not kill the process; it is being ran inside bash process, not node, 
# hence the process/node hosting react app is left alive
# killall -9 node || true

echo -e "${GREEN}>>> Copying iOS files ${NC}"
cd ${ROOT_DIR}
ext/ios/build.sh

echo -e "${GREEN}>>> Removing current module ${NC}"
cd ${ROOT_DIR}/${PROJECT_DIR}
react-native unlink ${SDK_PLUGIN_NAME} || true
react-native unlink ${TEST_PLUGIN_NAME} || true
react-native uninstall ${SDK_PLUGIN_NAME} || true
react-native uninstall ${TEST_PLUGIN_NAME} || true
rm -rfv node_modules/${SDK_PLUGIN_NAME}
rm -rfv node_modules/${TEST_PLUGIN_NAME}

echo -e "${GREEN}>>> Create new directory in node_modules ${NC}"
cd ${ROOT_DIR}/${PROJECT_DIR}
mkdir -p node_modules/${SDK_PLUGIN_NAME}
mkdir -p node_modules/${TEST_PLUGIN_NAME}

echo -e "${GREEN}>>> Copy modules to ${PROJECT_DIR}/node_modules/${SDK_PLUGIN_NAME} ${NC}"
cd ${ROOT_DIR}
rsync -a . ${PROJECT_DIR}/node_modules/${SDK_PLUGIN_NAME} --exclude=example --exclude=ext --exclude=scripts --exclude=test/lib --exclude=test/app --exclude=.git

echo -e "${GREEN}>>> Copy modules to ${PROJECT_DIR}/node_modules/${TEST_PLUGIN_NAME} ${NC}"
cd ${ROOT_DIR}/${TEST_PLUGIN_DIR}
rsync -a . ${ROOT_DIR}/${PROJECT_DIR}/node_modules/${TEST_PLUGIN_NAME}

echo -e "${GREEN}>>> Establish linkages ${NC}"
cd ${ROOT_DIR}/${PROJECT_DIR}
react-native link ${SDK_PLUGIN_NAME} || true
react-native link ${TEST_PLUGIN_NAME} || true

# TODO: change this hack to revert rubbish changes made automatically by react link/unlink
# echo -e "${GREEN}>>> Revert generated link/unlink changes... ${NC}"
# git checkout .

echo success. Run it from Xcode
