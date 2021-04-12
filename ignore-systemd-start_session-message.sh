#! /bin/bash
#
##################################################################################################################
#                                                                                      				 #
# ignore-systemd-start_session-message.sh -   	Script was made to ajust the /var/log/messages entrance and	 #
#                       			stop messages like session-slice from systemd     	         #
#                                                                                      				 #
# Author: Rafael Rittmeyer                                                          		  	         #
# Release date: 2021-04-06                                                               		         #
# Version code: 1.0                                                                    			         #
#                                                                                			         #
##################################################################################################################

## VARIABLES

release=$(cat /etc/redhat-release | awk '{print $4}' | cut -d . -f 1)
file1=/etc/rsyslog.d/ignore-systemd-session-slice.conf

## CHECK CENTOS RELEASE

echo "Checking CentOS Version"

if [ $release != 7 ]; then

        echo "The system versions is different of 7"
        exit 0

fi

## CHECK FILE EXISTENCY

echo "Checking file $file1"

if [ ! -f "$file1" ]; then

        echo 'if $programname == "systemd" and ($msg contains "Starting Session" or $msg contains "Started Session" or $msg contains "Created slice" or $msg contains "Starting user-" or $msg contains "Starting User Slice of" or $msg contains "Removed session" or $msg contains "Removed slice User Slice of" or $msg contains "Stopping User Slice of") then stop' > /etc/rsyslog.d/ignore-systemd-session-slice.conf

fi

## SETTING OWNERSHIP AND PERMISSIONS

echo "Setting ownership and permissions"

        chown root.zabbix /var/log/messages
        chmod 640 /var/log/messages

## RESTART SERVICES

echo "Restarting services"

        systemctl restart rsyslog zabbix-agent

