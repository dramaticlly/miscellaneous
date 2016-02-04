#!/bin/sh

echo 'start screen capturing'
while [ 1 ];
  do
  	vardate=$(date +%d\-%m\-%Y\_%H.%M.%S);
  	screencapture -t jpg -x ~/Downloads/dummy/$vardate.jpg;
  	sleep 30;
  done
