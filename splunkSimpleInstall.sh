#!/bin/bash
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
		curl "https://www.splunk.com/en_us/download/splunk-enterprise.html" > splunkDLSource.txt
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

awk '/data\-filename\=/' splunkDLSource.txt > contextData.txt ;
awk -F'"' '/\".*?"/{print $6, $8, $10, $12, $14, $16, $18, $20}' contextData.txt > fieldsBase.txt;

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

awk -v var="$osChoice" '$0~var' fieldsBase.txt > contextDataOS.txt;
case $archChoice in
    1)
      dlChoiceMessage="architecture: "
      awk '{print $3}' contextDataOS.txt > fromOSSelect.txt;;
    0)
      dlChoiceMessage="file extension: "
      awk '{print $2}' contextDataOS.txt | awk -F"." '{print $NF}' > fromOSSelect.txt;;
esac

fromOSSelect=$(cat fromOSSelect.txt)


PS3="Please Select $dlChoiceMessage"
select dlChoice in $fromOSSelect
do
	echo ""
        echo "You've selected $dlChoice"
        break
done

awk -v var="$dlChoice" '$3~var"-"' contextDataOS.txt > contextDataOSDecisionTree.txt;
awk -v var="$dlChoice" '$2~var' contextDataOS.txt > contextDataOSDecisionTree.txt;
#cat fromOSSelect.txt
#cat contextDataOSDecisionTree.txt
#cat contextDataOS.txt


linkDownload=$(awk '{print $1}' contextDataOSDecisionTree.txt)
echo "$(tput setaf 3)##---------------------------------------------------------------------##$(tput setaf 7)"
awk '{print "You have chosen to download splunk", $6, $3, "for", $4}' contextDataOSDecisionTree.txt;
echo "$(tput setaf 3)##---------------------------------------------------------------------##$(tput setaf 7)"

awk '{print "The link for your install will be:", $2}' contextDataOSDecisionTree.txt;

read -r -p "Are you sure you want to download this? [y/N] " response
case "$response" in
	[yY][eE][sS]|[yY])
		echo ""
		echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
		echo "BLEEP BLOOP BLEEP DOWNLOADING"
                echo "$(tput setaf 3)-----------------------------$(tput setaf 7)"
		curl -O $linkDownload
		;;
	*)
		echo "Ooops, I have not thought about no being an answer..."
		;;
esac

