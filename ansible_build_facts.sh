#!/bin/bash

#######################################
### CREATED BY RAFAEL RITTMEYER     ###
### CREATION DATE 17/08/23          ###
### LAST MODIFICATION 01/09/23      ###
#######################################

## VARIABLES LIST ##

FACT_DIR=/etc/ansible/facts.d
FACT_REDT=redt.fact
FACT_ZABBIX=zabbix.fact
AST_VER=$(cat PATH)
CROSSBAR_VER=$(cat PATH)
WEB_VER=$(cat PATH)
ZBXA=/etc/zabbix/zabbix_agentd.conf
ZBXP=/etc/zabbix/zabbix_proxy.conf

## FUNCTIONS LIST ##

function redt() {
    cd $FACT_DIR
        if [ ! -f $FACT_REDT ]; then
          
            printf "[version]\nasterisk:$AST_VER\ncrossbar:$CROSSBAR_VER\nweb:$WEB_VER\n" > $FACT_REDT

        else

            printf "[version]\nasterisk:$AST_VER\ncrossbar:$CROSSBAR_VER\nweb:$WEB_VER\n" > $FACT_REDT.new

            diff -u $FACT_REDT $FACT_REDT.new > $FACT_REDT.patch

                if [ -s $FACT_REDT.patch ]; then

                    patch -s < $FACT_REDT.patch
                
                fi
        
        fi
}

function zabbix-agent() {
    cd $FACT_DIR

        # set zabbix server ip when file not exist
        if [ ! -f $ZBXA ]; then
        
            printf "[zbxa]\nzbxa_server_ip:10.60.0.1\nzbxa_server_active_ip:10.60.0.1\n" > $FACT_ZABBIX
        
        elif [ -f $ZBXA ] && [ -f $FACT_ZABBIX ]; then

            ZBXA_SERVER=$(sed -n '98p' /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)

            printf "[zbxa]\nzbxa_server_ip:$ZBXA_SERVER\nzbxa_server_active_ip:$ZBXA_SERVER\n" > $FACT_ZABBIX.new

            diff -u $FACT_ZABBIX $FACT_ZABBIX.new > $FACT_ZABBIX.patch

                if [ -s $FACT_ZABBIX.patch ]; then

                    patch -s < $FACT_ZABBIX.patch
                
                fi

        else
            
            ZBXA_SERVER=$(sed -n '98p' /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
            
            printf "[zbxa]\nzbxa_server_ip:$ZBXA_SERVER\nzbxa_server_active_ip:$ZBXA_SERVER\n" > $FACT_ZABBIX
        
        fi 
}

function zabbix-proxy() {
    cd $FACT_DIR

        if [ ! -f $ZBXP ]; then

            printf "[zbxp]\nzbxp_start_pollers:5\nzbxp_unreach_pollers:3\n" >> $FACT_ZABBIX

        elif [ -f $ZBXP ] && [ -f $FACT_ZABBIX ]; then

            ZBXP_START_POLLERS=$(sed -n '269p' /etc/zabbix/zabbix_proxy.conf | cut -d = -f 2)

            ZBXP_UNREACH_POLLERS=$(sed -n '288p' /etc/zabbix/zabbix_proxy.conf | cut -d = -f 2)

            cp $FACT_ZABBIX $FACT_ZABBIX.new

            printf "\n[zbxp]\nzbxp_start_pollers:$ZBXP_START_POLLERS\nzbxp_unreach_pollers:$ZBXP_UNREACH_POLLERS\n" >> $FACT_ZABBIX.new

            diff -u $FACT_ZABBIX $FACT_ZABBIX.new > $FACT_ZABBIX.patch

                if [ -s $FACT_ZABBIX.patch ]; then

                    patch -s < $FACT_ZABBIX.patch

                fi

        fi
}

## CODE ZONE ##

if [ ! -d $FACT_DIR ]; then

    mkdir -p $FACT_DIR

fi

printf "### MAKING REDT ANSIBLE FACTS ###\n"
    redt

printf "### MAKING ZABBIX AGENT ANSIBLE FACTS ###\n"
    zabbix-agent

printf "### MAKING ZABBIX PROXY ANSIBLE FACTS ###\n"
    zabbix-proxy

rm -rf $FACT_ZABBIX.new $FACT_ZABBIX.patch $FACT_REDT.new $FACT_REDT.patch
