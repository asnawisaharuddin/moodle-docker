#!/bin/bash

# generate ssh key
if [ ! -f /var/www/moodledata/id_rsa ]; then
    ssh-keygen -q -t rsa -N '' -f /var/www/moodledata/id_rsa
fi

/usr/bin/supervisord
