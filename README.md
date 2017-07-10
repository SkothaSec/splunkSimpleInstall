# splunkSimpleInstall
Automate the install and upgrade process for splunk from downloading the install file to installation complete.

## What the script does so far
It starts off by doing a self check to ensure directory structure for the program is correct.
If it is not correct it creates the directory structure and move the script into the new directory.

Once the initial check is complete it continues to download the html source from splunk downloads for enterprise.
This is done with a curl command.

After the source is downloaded it matches and extracts lines containing splunk installation files.

The user is then asked what operating system they want the file for, then narrows down to the arch and file extension.
Throughout the questions the script will filter down to the needed file.

Once the script identifies the file, it will ask the user to verify that the correct file was found.
If the file was correct the user will be asked if they want to download the file.
If the user accepts, the file will be downloaded via curl.

## How to use
run as root
place shell script in /opt/
run command: chmod +x installUpgradeSplunk.sh
execute the script: ./installUpgradeSplunk.sh

## Next step
Allow user to install splunk from the script.

## Status
NOTE: this bash script has only been tested on an ubuntu 16.04 server.

10 July 2017 - All relavant files should successfuly download and go into the directory splunkUpgradeInstall\downloads.
