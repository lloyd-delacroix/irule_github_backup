#!/bin/bash
#Import settings from config file
source /home/root/irule_export/config.sh
#Export current irules from F5
tmsh list ltm rule > /tmp/rules.txt
#Check if file has changed since last run
hash=`sha256sum /tmp/rules.txt`
if [[ $(< /tmp/rules.sha) != $hash ]]; then
#Encode irules to base64
file_content=$(base64 -w0 /tmp/rules.txt)
#Get the SHA256 hash of the current rules file from github
json=$(curl -s --header "Authorization: token $token" $url)
sha=$(grep -Po '"sha": "\K[a-z0-9]+' <<<$json)
#Prepare data to be sent to github
data='{"message":"Created via API","committer": {"name": "'$name'","email": "'$email'"},"content": "'$file_content'","sha": "'$sha'"}'
#Commit updated irules to github
curl -s -X PUT --header "Authorization: token $token" --data @- $url <<CURL_DATA
$data
CURL_DATA
sha256sum /tmp/rules.txt > /tmp/rules.sha
fi
