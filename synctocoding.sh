#!/bin/bash
git clone -b master "https://kmahyyg:${GITHUB_PERTKN}@github.com/kmahyyg/kmahyyg.github.io.git" /tmp/buld_y && cd /tmp/buld_y && git push --force "https://kmahyyg:${CODING_PERTKN}@${CO_REF}" master
echo "Return status code $?"
exit 0
