#!/bin/bash
#This script uses hammer cli to query the satellite DB
#The output is saved to $PATCHRPT as a text file.  
#Enter the name of your satellite server in the $SATSVR so that it is filtered out of the report. Satellite patching is separate.
#Author: Norman Owens - Red Hat

for i in `hammer host list | grep -v virt-who | grep -v NAME | grep -v $SATSVR | awk '{print $3}'`
