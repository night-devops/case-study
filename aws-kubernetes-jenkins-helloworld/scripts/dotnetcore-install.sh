#!/usr/bin/env bash

VERSION=$1

# install dotnet core sdk 
# https://www.microsoft.com/net/core#linuxubuntu
if [ ! -f /usr/bin/dotnet ]; then
	curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
	&& sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
	&& sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list' \
	&& sudo apt-get -qqy update \
	&& sudo apt-get -qqy install dotnet-sdk-$1
fi

# first time running dotnet tool requires setting up package cache
dotnet nuget