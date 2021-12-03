#!/bin/bash

# License Falcon Sensor Installer
# By Kevin Guay (hello at kevinguay dot com)

# Script to add licensing information to the MacOS falcon sensor installer.
# Instruction for manually editing the installer file can be found at https://www.kevinguay.com/posts/macos-falcon-sensor/
# This should be run on a system running MacOS

# Check that the pkgutil is installed
if ! [ -x "$(command -v pkgutil)" ]; then
  echo Error: git is not installed.
  exit 1
fi

# Delete temporary pkg file if exists
pkg_temp="/tmp/FalconSensor.unpkg"
if [ -d "$pkg_temp" ]; then
  rm -rf $pkg_temp
fi

# Unpackage the pkg (installer)
pkgutil --expand $1 $pkg_temp

postinstall_file="$pkg_temp/sensor-kext.pkg/Scripts/postinstall"
sed -i '' 's|VALUE=""|VALUE="'"$2"'"|g' $postinstall_file
sed -i '' 's|^loadSensor|function licenseSensor()\n{\n    "$CS_BIN_PATH/falconctl" license "'"$2"'"\n}\n\nlicenseSensor\nloadSensor|g' $postinstall_file

postinstall_file="$pkg_temp/sensor-sysx.pkg/Scripts/postinstall"
sed -i '' 's|VALUE=""|VALUE="'"$2"'"|g' $postinstall_file
sed -i '' 's|^loadSensor|function licenseSensor()\n{\n    "$CS_BIN_PATH/falconctl" license "'"$2"'"\n}\n\nlicenseSensor\nloadSensor|g' $postinstall_file

# Re-package file
new_filename=`echo $1 | cut -f1 -d'.'`
pkgutil --flatten $pkg_temp $new_filename"WithID.pkg"
