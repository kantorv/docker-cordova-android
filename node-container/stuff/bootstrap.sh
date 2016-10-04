#!/bin/bash

ANGULAR_ROOT=/angular-project
CORDOVA_ROOT=/android-project


APP_NAME="$1"
APP_BUNDLE="$2"
[[ -z $APP_NAME ]] && echo "No app name provided" && exit 1

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/android-sdk-linux/tools:/android-sdk-linux/platform-tools
export ANDROID_HOME=/android-sdk-linux
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export NODE_PATH=/usr/lib/nodejs:/usr/lib/node_modules:/usr/share/javascript:/usr/local/lib/node_modules

cd $CORDOVA_ROOT
echo "Generating app: $APP_NAME"
echo "n" | cordova create $APP_NAME  $APP_BUNDLE
ln -s $CORDOVA_ROOT/$APP_NAME $CORDOVA_ROOT/app_root
sed -i "s|HelloCordova|$APP_NAME|" $CORDOVA_ROOT/$APP_NAME/config.xml



cd $ANGULAR_ROOT
npm install gulp
echo "$APP_NAME" | yo mobileangularui


#ncu -ua
#npm update
#ncu -m bower -ua
#bower update

gulp build
rm -rf  $CORDOVA_ROOT/$APP_NAME/www
ln -s $ANGULAR_ROOT/www   $CORDOVA_ROOT/$APP_NAME

cd $CORDOVA_ROOT/app_root
cordova platform add android
cordova build

supervisorctl start gulp-server
