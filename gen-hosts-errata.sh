#!/bin/bash
#This script uses hammer cli to query the satellite DB and produce a HOST errata report.
#The output is saved to $PATCHRPT as a text file.  
#Enter the name of your satellite server in the $SATSVR so that it is filtered out of the report. Satellite patching is separate.
#In order to convert patch.rpt.txt to pdf follow these 3 steps
#1.yum install vim
#2 yum install ghostscript <to get ps2pdf>
#3 vim patch.rpt.txt  -c "hardcopy > patch.rpt.ps | q"; ps2pdf patch.rpt.ps
#Author: Norman Owens - Red Hat

#MAILTO="user1@example.com user2@example.com"
UPTODATE=0
STALE=0
SVRCOUNT=0
SATSVR=<enter your sat server here>
DTE=`date +%m/%d/%Y`
DTE2=`date +%m%d%Y`
OUTFILE=/tmp/patch.staging.txt
PATCHRPT=/tmp/patch.rpt.txt
PATCHRPTPS=/tmp/patch.rpt.ps
PATCHRPTPDF=/tmp/patch.rpt.pdf
PATCHRPTHTML=/tmp/patchrpt-$DTE2.html

cat /dev/null > $OUTFILE
cat /dev/null > $PATCHRPT

for i in `hammer host list | grep -v virt-who | grep -v NAME | grep -v $SATSVR | awk '{print $3}'`
do
  hammer host info --id $i | egrep '^Name|Upgradable Packages|Enhancement|Bug Fix|Security' | tr -d '\n' | awk '{print $2" "$5" "$7" "$10" "$12}' | tee -a $OUTFILE
done

clear

while read NAM UPG ENH BUG SEC
do
  if [[ $UPG -eq 0 ]] && [[ $ENH -eq 0 ]] && [[ $BUG -eq 0 ]] && [[ $SEC -eq 0 ]]
  then
    let UPTODATE++
  else
    let STALE++
  fi
  let SVRCOUNT++
done<$OUTFILE

#Code to build text file
echo "Patch Systems Report $DTE" | tee -a $PATCHRPT
echo "Total Systems: $SVRCOUNT" | tee -a $PATCHRPT
echo "Systems up to date: $UPTODATE" | tee -a $PATCHRPT
echo "Systems remaining to be patched: $STALE" | tee -a $PATCHRPT

#Code to build html file
echo "<!DOCTYPE html>" > $PATCHRPTHTML
echo "<html><head><title>RHEL Patch Report</title></head><body><p>" >> $PATCHRPTHTML
echo "<h1>RHEL Patch Report  $DTE </h1>" >> $PATCHRPTHTML
echo "<h2>Total Systems: $SVRCOUNT <br>" >> $PATCHRPTHTML
echo "Systems up to date: <font color='green'>$UPTODATE</font><br>" >> $PATCHRPTHTML
echo "Systems remaining to be patched: <font color='red'>$STALE</font></h2></body></html>" >> $PATCHRPTHTML

#Code for converting text file to pdf file
#vim $PATCHRPT  -c "hardcopy > $PATCHRPTPS | q"; ps2pdf $PATCHRPTPS

#Email pdf file to MAILTO list
#echo "RHEL Patching Report attached" | mailx -s "RHEL Patching Report" -a $PATCHRPTPDF $MAILTO 
