#!/bin/bash

echo 
echo "Check mysql staus"

isRun="N"
while [ "$isRun" != "Y" ]; do
	echo -ne "."
	sleep 2
	status=`service mysqld status | grep running`
	if [ "$status" != "" ]; then isRun="Y"; fi
done
echo
