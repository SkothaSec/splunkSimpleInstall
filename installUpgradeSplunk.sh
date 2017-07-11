#!/bin/bash
######################################################
## Checking that correct directory structure exists ##
## If structure does not exist, script will create  ##
## it and move the script inside of the new dir.    ##
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
                mkdir $mainPath;
                mkdir $ogData;
                mkdir $cData;
                mkdir $downloads;
                mkdir $initialChecks;
                mv mainDirCheck.txt $initialChecks/
                mv subDirCheck.txt $initialChecks/
                mv installUpgradeSplunk.sh $mainPath
                echo ""
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                echo "BLEEP BLOOP BLEEP"
                echo "Initial tasks complete"
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
                ;;
esac


######################################################
##----------------Download File --------------------##
######################################################

echo ""
echo "$(tput setaf 3)-------------------------------------------$(tput setaf 1)WARN$(tput setaf 3)-----------------------------------------------$(tput setaf 7)"
echo "This script assumes you are good with reaching out to $(tput setaf 5)splunk.com $(tput setaf 7)and $(tput setaf 3)scaping/downloading data.$(tput setaf 7)"
echo "$(tput setaf 3)----------------------------------------------------------------------------------------------$(tput setaf 7)"
echo ""

read -r -p "Are you sure you are okay with this? By selecting $(tput setaf 3)yes$(tput setaf 7), your device will begin $(tput staf 3)scraping$(tput setaf 7). $(tput setaf 6)[$(tput setaf 3)y/N$(tput setaf 6)]$(tput setaf 7): " response
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

awk '/data\-filename\=/' $ogData/splunkDLSource.txt > $cData/contextData.txt ;
awk -F'"' '/\".*?"/{print $6, $8, $10, $12, $14, $16, $18, $20}' $cData/contextData.txt > $cData/fieldsBase.txt;

###########################################################################################
##                                          Awk Fields                                   ##
##---------------------------------------------------------------------------------------##
## $1 = installFileLink | $2 = linkFilename    | $3 = arch               | $4 = systemOS ##
## $5 = splunkVersion   | $6 = linkDownloadMD5 | $7 = linkDownloadSHA512                 ##
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
      awk '{print $3}' $cData/contextDataOS.txt | sed 's/.._//g' > $cData/fromOSSelect.txt;;
    0)
      dlChoiceMessage="file extension: "
      awk '{print $2}' $cData/contextDataOS.txt | awk -F"." '{print $NF}' > $cData/fromOSSelect.txt;;
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
#cat fromOSSelect.txt
#cat contextDataOSDecisionTree.txt
#cat contextDataOS.txt


linkDownload=$(awk '{print $1}' $cData/contextDataOSDecisionTree.txt)
echo "$(tput setaf 3)##---------------------------------------------------------------------##$(tput setaf 7)"
awk '{print "## You have chosen to download splunk", $6, $3, "for", $4}' $cData/contextDataOSDecisionTree.txt;
echo "$(tput setaf 3)##---------------------------------------------------------------------##$(tput setaf 7)"

awk '{print "The link for your install will be:", $2}' $cData/contextDataOSDecisionTree.txt;

################################################
## Begin download of splunk installation link ##
################################################

read -r -p "Are you sure you want to $(tput setaf 3)download$(tput setaf 7) this? $(tput setaf 6)[$(tput setaf 3)y/N$(tput setaf 6)]$(tput setaf 7): " response
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
