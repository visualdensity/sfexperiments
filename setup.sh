#!/bin/bash

# -------------------
# Setup script
#
# To install as standard dev environment, run:
#   ./setup.sh
#
# If you wish to setup production environment, run:
#   ./setup.sh -p
# -------------------

while getopts ":pu" opt; do
    case $opt in
	u)
	    update=1
	    echo "Setting up production environment..." >&2
	    ;;
	p)
	    production=1
	    echo "Setting up production environment..." >&2
	    ;;
    esac
done

# make sure it's deleteable
sudo chmod -R 777 app/cache app/logs

# get submodules
git submodule init
git submodule update

if [ ! -f "composer.phar" ]; then
    # get latest composer.phar
    curl -s http://getcomposer.org/installer | php
fi

if [ -n "$update" ]; then
    # Install dependencies
    php composer.phar udpate
else 
    # Install dependencies
    php composer.phar install
fi

# Setup assets and assetics
if [ -n "$production" ]; then
    php app/console assetic:dump --env=prod --no-debug
else
    # Override prod setting and use symlink for assets instead
    php app/console assets:install --symlink --env=dev
    php app/console assetic:dump --env=dev
fi

# make sure everything is writeable
sudo chmod -R 777 app/cache app/logs
