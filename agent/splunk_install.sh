#!/bin/bash

SPLUNK_HOME=$1
if [ -z "$SPLUNK_HOME" ]; then
	echo "Syntax: $0 {SPLUNK_HOME}"
	exit 1
fi

if [ -f $SPLUNK_HOME/.installed ]; then
	echo "Already installed, moving on..."
	exit
fi

# install it
$SPLUNK_HOME/bin/splunk start --accept-license --answer-yes --no-prompt
$SPLUNK_HOME/bin/splunk install app /agent/serverufapp.spl -auth admin:changeme

touch $SPLUNK_HOME/.installed
