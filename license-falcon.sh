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
temp_pkg="/tmp/FalconSensor.unpkg"
if [ -d "$temp_pkg" ]; then
  rm -r $temp_pkg
fi

# Store the postinstall file path for reference
pkg_temp="/tmp/FalconSensor.unpkg"
postinstall_file="/tmp/FalconSensor.unpkg/sensor.pkg/Scripts/postinstall"
temp_file="/tmp/postinstall"

# Unpackage the pkg (installer)
pkgutil --expand $1 $pkg_temp

# Delete loadSensor line in postinstall and store in temp file
sed 's/^loadSensor//g' $postinstall_file > $temp_file

# Append license information to temp file
cat <<EOT >> $temp_file
function licenseSensor()
{
    /Library/CS/falconctl license $2
}

licenseSensor
loadSensor
EOT

# Move temp file to postinstall file
mv $temp_file $postinstall_file

# Re-package file
new_filename=`echo $1 | cut -f1 -d'.'`
pkgutil --flatten $pkg_temp $new_filename"WithID.pkg"
