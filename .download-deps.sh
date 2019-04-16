#!/bin/bash

HUGODEB=/home/travis/.hugopkg/hugo.deb
STASHA2DEB=5d3f7e565bc3224f744bef2c07bedf3e8c7d821a9d757bde6db46ff5e96e179a

sudo apt-get update && sudo apt-get install wget ca-certificates -y
mkdir -p /home/travis/.hugopkg/

cd /home/travis/.hugopkg

if [ -f "$HUGODEB" ]; then
    CURSHA2DEB=`sha256sum ${HUGODEB} | awk '{print $1}'`
    if [ ${CURSHA2DEB} == ${STASHA2DEB} ]; then
        exit 0
    fi
else 
    wget --no-check-certificate https://github.com/gohugoio/hugo/releases/download/v0.54.0/hugo_0.54.0_Linux-64bit.deb -O ${HUGODEB}
    sudo dpkg -i ${HUGODEB}
fi
