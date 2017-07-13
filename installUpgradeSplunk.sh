#!/bin/bash
######################################################
## Checking that correct directory structure exists ##
##If structure does not exist, script will create   ##
## it and move the script inside of the new dir.  ##
######################################################
mainDirCheck=$(pwd | awk -F"/" '{print $NF}' > mainDirCheck.txt)
subDirCheck=$(ls -R | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$8 }' > subDirCheck.txt)
$mainDirCheck;
$subDirCheck;
mainDir=$(cat mainDirCheck.txt)
subDir=$(cat subDirCheck.txt)
case $mainDir in
        splunkInstallUpgrade)
        echo ""
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                echo "BLEEP BLOOP BLEEP"
                echo "Initial tasks Complete"
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                mainPath="./"
                ogData="./ogData"
                cData="./cData"
                downloads="./downloads"
                initialChecks="./initialChecks"
                mv mainDirCheck.txt $initialChecks/;
                mv subDirCheck.txt $initialChecks/;
                ;;
        *)
	        echo ""
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                echo "BLEEP BLOOP BLEEP"
                echo "Creating directories in current path for upgrade script"
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"

	        mainPath="splunkInstallUpgrade"
                ogData="splunkInstallUpgrade/ogData"
                cData="splunkInstallUpgrade/cData"
                downloads="splunkInstallUpgrade/downloads"
                initialChecks="splunkInstallUpgrade/initialChecks"
		md5Path="splunkInstallUpgrade/downloads/md5"
		sha512Path="splunkInstallUpgrade/downloads/sha512"

                mkdir $mainPath;
                mkdir $ogData;
                mkdir $cData;
                mkdir $downloads;
                mkdir $initialChecks;
		mkdir $md5Path;
		mkdir $sha512Path;

                mv mainDirCheck.txt $initialChecks/
                mv subDirCheck.txt $initialChecks/
                mv installUpgradeSplunk.sh $mainPath
		$sleeping

                echo ""
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                echo "BLEEP BLOOP BLEEP"
                echo "Initial tasks complete"
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                ;; esac


######################################################
##----------------Download File --------------------##
######################################################

echo ""
echo "$(tput setaf 3)-------------------------------------------$(tput setaf 1)WARN$(tput setaf 3)-----------------------------------------------$(tput setaf 7)"
echo "This script assumes you are good with reaching out to $(tput setaf 5)splunk.com $(tput setaf 7)and $(tput setaf 3)scaping/downloading data.$(tput setaf 7)"
echo "$(tput setaf 3)----------------------------------------------------------------------------------------------$(tput setaf 7)"
echo ""

read -r -p "Are you sure you are okay with this? By selecting $(tput setaf 3)yes$(tput setaf 7), your device will begin scraping. $(tput setaf 6)[$(tput setaf 3)y/N$(tput setaf 6)]$(tput setaf 7) " response
case "$response" in
        [yY][eE][sS]|[yY])
        echo ""
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                echo "BLEEP BLOOP BLEEP"
		echo "YANKING STUFF FROM SPLUNK.COM"
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
		curl "https://www.splunk.com/en_us/download/splunk-enterprise.html" > $ogData/splunkDLSource.txt
                ;;
        *)
                echo "Ooops, I have not thought about no being an answer... exiting script"
			exit
                	;;
esac

echo ""
echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
echo "Chopping the html up"
echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
echo ""

awk '/data\-filename\=/' $ogData/splunkDLSource.txt > $cData/contextData.txt;
awk -F'"' '/\".*?"/{print $6, $8, $10,$12, $14, $16, $18, $20}' $cData/contextData.txt > $cData/fieldsBase.txt;

###########################################################################################
##                                          Awk Fields 					 ##
##---------------------------------------------------------------------------------------##
## $1 = installFileLink | $2 = linkFilename | $3 = arch | $4 = systemOS
## $5 = splunkVersion | $6 = linkDownloadMD5 | $7 = linkDownloadSHA512 					 ##
###########################################################################################

PS3="What Operating System are you installing on?"
select osChoice in linux mac windows solaris
	do
        	case $osChoice in
                	linux)
                        	echo "You've Selected: $osChoice"
                        	archChoice=0
                                	break
                                	;;
                	mac)
                        	echo "You've Selected: $osChoice"
                        	archChoice=0
                                	break
                                	;;
                	windows)
                        	echo "You've Selected: $osChoice"
                        	archChoice=1
                                	break
                                	;;
                	solaris)
                        	echo "You've Selected: $osChoice"
                        	archChoice=0
                                	break
                                	;;
                	*)
                        	echo "Invalid Selection: Please try again(1-4)"
                                ;;
        esac
done ;

###############################################################
## Outputs lines matching OS selction into contextDataOS.txt ##
###############################################################
echo ""
echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
echo "BLEEP BLOOP BLEEP MATCHING"
echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
echo ""
awk -v var="$osChoice" '$0~var' $cData/fieldsBase.txt > $cData/contextDataOS.txt;

case $archChoice in
    1)
      dlChoiceMessage="architecture: "
      awk '{print $3}' $cData/contextDataOS.txt | sed 's/.._//g' > $cData/fromOSSelect.txt
	;;
    0)
      dlChoiceMessage="file extension: "
      awk '{print $2}' $cData/contextDataOS.txt | awk -F"." '{print $NF}' > $cData/fromOSSelect.txt
	;;
 esac

fromOSSelect=$(cat $cData/fromOSSelect.txt)

PS3="Please Select $dlChoiceMessage"
select dlChoice in $fromOSSelect
do
	echo ""
	echo "You've selected $dlChoice"
    	break
done

awk -v var="$dlChoice" '$3=var' $cData/contextDataOS.txt > $cData/contextDataOSDecisionTree.txt;
awk -v var="$dlChoice" '$2~var' $cData/contextDataOS.txt > $cData/contextDataOSDecisionTree.txt;

linkDownload=$(awk '{print $1}' $cData/contextDataOSDecisionTree.txt)
echo "$(tput setaf 3)##---------------------------------------------------------------------##$(tput setaf 7)"
awk '{print "You have chosen to download splunk", $6, $3, "for", $4}' $cData/contextDataOSDecisionTree.txt;
echo "$(tput setaf 3)##---------------------------------------------------------------------##$(tput setaf 7)"
awk '{print "The link for your install will be:", $2}' $cData/contextDataOSDecisionTree.txt;

read -r -p "Are you sure you want to download this? [y/N] " response
case "$response" in
	[yY][eE][sS]|[yY])
		echo ""
		echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
		echo "BLEEP BLOOP BLEEP DOWNLOADING"
    		echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
		curl -O $linkDownload;
		mv splunk*.* $downloads/
		;;
	*)
		echo "Ooops, I have not thought about no being an answer..."
		;;
esac


################################################
##---------------Start Installation-----------##
################################################
## --> this is the next step.
##########################
## File integrity check ##
##########################

fileDownloaded=$(awk '{print $2}' $cData/contextDataOSDecisionTree.txt)

md5ToFile=$(awk '{print $7}' $cData/contextDataOSDecisionTree.txt > $cData/contextInstallMd5.txt)
md5Link=$(cat $cData/contextInstallMd5.txt)
md5FileParse=$(awk -F"/" '{print $NF}' $cData/contextInstallMd5.txt > $cData/contextFilenameMd5.txt)
md5File=$(cat $cData/contextFilenameMd5.txt)

sha512ToFile=$(awk '{print $8}' $cData/contextDataOSDecisionTree.txt > $cData/contextInstallSha512.txt)
sha512Link=$(cat $cData/contextInstallSha512.txt)
sha512FileParse=$(awk -F"/" '{print $NF}' $cData/contextInstallSha512.txt > $cData/contextFilenameSha512.txt)
sha512File=$(cat $cData/contextFilenameSha512.txt)

echo ""
echo "-------------------------------------------------"
echo "-----------------Integrity Check-----------------"
echo "-------------------------------------------------"
echo ""
echo ""

PS3="How would you like to check the integrity of your install file? "
select intCheck in md5 sha512 both skip
do
        case $intCheck in
                md5)
                        echo "You've Selected: $intCheck"
			echo ""
			echo "starting integrity check (downloading $intCheck file)"
			echo ""

			md5sum $downloads/$fileDownloaded | awk '{print $1}' > $downloads/md5/checkMd5Sum.txt;
			curl -O $md5Link;
			mv $md5File $downloads/md5;
			awk '{print $4}' $downloads/md5/$md5File >> $downloads/md5/checkMd5Sum.txt
			echo ""
			echo "Checksum outputs: "

			cat $downloads/md5/checkMd5Sum.txt

			intMatchValue=$(uniq -D $downloads/md5/checkMd5Sum.txt | wc -l | awk '{print $1}')
                                break
                                ;;
                sha512)
                        echo "You've Selected: $intCheck"
			echo ""
			echo "starting integrity check."
			echo ""
                        sha512sum $downloads/$fileDownloaded | awk '{print $1}' > $downloads/sha512/checkSha512Sum.txt;
                        curl -O $sha512Link;
                        mv $sha512File $downloads/sha512;
                        awk '{print $1}' $downloads/sha512/$sha512File >> $downloads/sha512/checkSha512Sum.txt

                        echo ""
                        echo "Checksum outputs: "
                        cat $downloads/sha512/checkSha512Sum.txt

                        intMatchValue=$(uniq -D $downloads/sha512/checkSha512Sum.txt | wc -l | awk '{print $1}')
			intMatchValue=$(($intMatchValue + 1))
                                break
                                ;;
                both)
			echo ""
			echo "You've Selected: SHA512 and MD5"
                        echo ""
                        echo "starting integrity check (downloading $intCheck files)"
                        echo ""
                        md5sum $downloads/$fileDownloaded | awk '{print $1}' > $downloads/md5/checkMd5Sum.txt;
                        curl -O $md5Link;
                        mv $md5File $downloads/md5;
                        awk '{print $4}' $downloads/md5/$md5File >> $downloads/md5/checkMd5Sum.txt

                        echo ""
                        echo "md5 outputs: "
                        cat $downloads/md5/checkMd5Sum.txt

                        mdMatchValue=$(uniq -D $downloads/md5/checkMd5Sum.txt | wc -l | awk '{print $1}')
			mdMatchValue=$((mdMatchValue + 2))
               	###############################
		## Break between md5 and sha ##
		###############################
                        sha512sum $downloads/$fileDownloaded | awk '{print $1}' > $downloads/sha512/checkSha512Sum.txt
                        curl -O $sha512Link;
                        mv $sha512File $downloads/sha512;
                        awk '{print $1}' $downloads/sha512/$sha512File >> $downloads/sha512/checkSha512Sum.txt
                        echo ""
                        echo "Checksum outputs: "
                        cat $downloads/sha512/checkSha512Sum.txt
                        shaMatchValue=$(uniq -D $downloads/sha512/checkSha512Sum.txt | wc -l | awk '{print $1}')
			shaMatchValue=$((shaMatchValue + 3))
			intMatchValue=$(($shaMatchValue + $mdMatchValue))
                 		break
                                ;;
                skip)
                        echo "Skipping integrity check"
                                break
                                ;;
                *)
                        echo "Invalid Selection: Please try again(1-4)"
                                ;;
        esac
done

case $intMatchValue in
	9)
		echo ""
		echo "matched SHA512 and MD5, continuing"
		echo ""
		;;
	5)
		echo ""
		echo "not sure how this happened, but you matched SHA512 but not MD5"
		echo ""
		;;
	4)
		echo ""
		echo "not sure how this happened, but you matched MD5 but not SHA"
		echo ""
		;;
	3)
		echo ""
		echo "SHA512 Matched Continuing"
		echo ""
		;;
	2)
		echo ""
		echo "MD5 Matched Continuing"
		echo ""
		;;
	1)
		echo ""
		echo "THERE ARE 512 REASONS YOU SHOULD NOT INSTALL THIS FILE"
		echo ""
		;;
	0)
		echo ""
		echo "BURN THE FILE THE MD5 CHECK DIDN'T MATCH"
		echo ""
		;;
esac
###########################################################################################
## Install/Upgrade Splunk on local system Note this will only work for Tar and Deb files ##
## Also have not made option for splunk outside of /opt/ if you have splunk installed    ##
## outside of opt, please do not run this script yet.                                    ##
###########################################################################################

PS3="Would you like to proceed?"
select installDecision in installation upgrade quit
do
        case $installDecision in
                installation)
                        echo "You've selected: $installDecision"
				break
                                ;;
                upgrade)
                        echo "You've selected: $installDecision"
				break
				;;

                quit)
                        echo "You've Selected: $installDecision"
                        echo "Exiting"
                        	exit
                                ;;
        esac
done

echo "BEFORE CONTINUING, This script is currently only designed to install/upgrade splunk on linux systems where the download file extension is either tar or deb"
echo "If you are upgrading, do no use this script *especially* if your splunk is not installed in the /opt/ path."

read -r -p "Do you understand that the functionality is limited and you probably shouldn't run this in any form of production environment? [y/N]" response
case "$response" in
        [yY][eE][sS]|[yY])
        echo ""
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                echo "BLEEP BLOOP BLEEP"
		echo "CONTINUING"
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
		curl "https://www.splunk.com/en_us/download/splunk-enterprise.html" > $ogData/splunkDLSource.txt
                ;;
        *)
                echo "Ooops, I have not thought about no being an answer... exiting script"
			exit
	                ;;
esac

SPLUNK_BIN="/opt/splunk/bin"

echo "$(tput setaf 3)-----------------------------------------------------------------------------$(tput setaf 7)"
echo "flags and customization will be added in the future, for now, this is a super basic setup"
echo "$(tput setaf 3)-----------------------------------------------------------------------------$(tput setaf 7)"
echo ""
echo ""
echo "$(tput setaf 3)-----------------------------------------------------------------------------$(tput setaf 7)"
echo "Please be super careful in option unless you don't mind your splunk being uninstalled because you clicked 3 (uninstall)"
echo "$(tput setaf 3)-----------------------------------------------------------------------------$(tput setaf 7)"
echo ""
echo ""
PS3="Do you want to install, uninstall or upgrade? "

select installOrUpgrade in "install" upgrade uninstall quit
do
        case $installOrUpgrade in
                "install")
			echo ""
                        echo "You've selected: $installOrUpgrade"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo "BLEEP BLOOP BLEEP"
  		        echo "Installing, first time installation user is admin and password is change me"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
			echo ""

			echo ""
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo "UNPACKING TAR FILE"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo ""
			tar zxf $downloads/$fileDownloaded -C /opt;

                        echo ""
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo "STARTING SPLUNK AND ACCEPTING LICENSE"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo ""
			$SPLUNK_BIN/splunk start --accept-license;

                        echo ""
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo "ENABLING BOOT START"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo ""

			$SPLUNK_BIN/splunk enable boot-start;

                        echo ""
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo "CHECKING STATUS OF SPLUNK"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo ""
			$SPLUNK_BIN/splunk status;

                        echo ""
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo "SHOWING SPLUNK PORTS"
                        echo "$(tput setaf 6)USERNAME$(tput setaf 7): $(tput setaf 1)admin $(tput setaf 6)PASSWORD$(tput setaf 7): $(tput setaf 1)changeme"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo ""

			$SPLUNK_BIN/splunk show splunkd-port;
			$SPLUNK_BIN/splunk show web-port;
			$SPLUNK_BIN/splunk show servername;
			$SPLUNK_BIN/splunk show default-hostname;
			break
                        ;;
                upgrade)
                        echo "You've selected: $installOrUpgrade"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo "BLEEP BLOOP BLEEP"
        	        echo "Upgrade coming in next few days"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
			break
                       ;;
                uninstall)
                        echo "You've selected: $installOrUpgrade"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        echo "BLEEP BLOOP BLEEP"
                        echo "disabling Boot Start"
                        echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                        $SPLUNK_BIN/splunk disable boot-start;
			$SPLUNK_BIN/splunk stop;
			kill -9 `ps -ef | grep splunk | grep -v grep | awk '{print $2;}'`;
			rm -rf /opt/splunk;
			rm -rf /opt/splunkdata;
			break
                        ;;
                quit)
                        echo "You've Selected: $installOrUpgrade"
                        echo "Exiting"
                        exit
                        ;;
        esac
done ;

exit
