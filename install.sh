#!/bin/sh

swift build --configuration release

BINARY=.build/release/CoreDataModelGenerator
INSTALL_LOCATION=/usr/local/bin

if [ -w $INSTALL_LOCATION ]; then
    cp $BINARY $INSTALL_LOCATION
else
    sudo cp $BINARY $INSTALL_LOCATION
fi