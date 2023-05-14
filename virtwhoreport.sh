#!/bin/bash
#This script prints a report of the Satellite virt-who hosts and virt-who guests. Tested on RHEL8.7
#Create TMPUSER in Satellite GUI with Administrator Role
#Author: Norman Owens - Red Hat

TMPUSER=<satellite user>
TMPPWD=<satellite user pw>
TMPSAT=<satellite server>
TMPFILE=/tmp/file.csv

# Create csv file and add header
echo "Name,Subscription Status,Should be entitled?,Number of Guests,average per node,Notes" > $TMPFILE 

#Get virt-who hosts
for i in $(curl --silent --request GET --insecure --user $TMPUSER:$TMPPWD https://$TMPSAT/api/hosts?search=virt-who | jq '.results | .[].name' | sed 's/"//g')
do
  echo $i
  #Get list of virt-who guests
  TMPCOUNT=$(curl --silent --request GET --insecure --user $TMPUSER:$TMPPWD https://$TMPSAT/api/hosts/$i | jq '.subscription_facet_attributes.virtual_guests | .[].name' | sed 's/"//g'| wc -l)

  #Get subscription_status
  TMPLABEL=$(curl --silent --request GET --insecure --user $TMPUSER:$TMPPWD https://$TMPSAT/api/hosts/$i | jq '.subscription_status_label' | sed 's/"//g')

  #List if fully entitled
  if [[ $TMPLABEL = "Fully entitled" ]]
  then
     TMPENT=Yes
  else
     TMPENT=No
  fi
echo "$i,$TMPLABEL,$TMPENT,$TMPCOUNT,," >> $TMPFILE 
done 
