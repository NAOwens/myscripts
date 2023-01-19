#!/bin/bash
#This script uses hammer cli to query the satellite DB and produce a HOST errata report.
#The output is saved to $PATCHRPT as a text file.  
#Enter the name of your satellite server in the $SATSVR so that it is filtered out of the report. Satellite patching is separate.
#Author: Norman Owens - Red Hat

UPTODATE=0
STALE=0
SVRCOUNT=0
SATSVR=<enter your sat server here>
OUTFILE=/tmp/patch.staging.txt
PATCHRPT=/tmp/patch.rpt.txt

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

echo "Patch Systems Report `date +%m/%d/%Y`" | tee -a $PATCHRPT
echo "Total Systems: $SVRCOUNT" | tee -a $PATCHRPT
echo "Systems up to date: $UPTODATE" | tee -a $PATCHRPT
echo "Stale systems: $STALE" | tee -a $PATCHRPT
