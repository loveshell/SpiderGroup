#!/bin/bash
echo "================================================"
WDIR=`dirname $0`
pwd
cd $WDIR
WDIR=`pwd`
pwd


#for cron use...load env...
cd ~/
source .bash_profile
source .bashrc
#printenv
cd $WDIR

./spidergroup.rb dyqq