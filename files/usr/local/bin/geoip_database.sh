#!/usr/bin/env bash

mkdir -p /usr/share/GeoIP
wget -q --show-progress -P /usr/share/GeoIP/ http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip -f /usr/share/GeoIP/GeoIP.dat.gz
wget -q --show-progress -P /usr/share/GeoIP/ http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
gunzip -f /usr/share/GeoIP/GeoLiteCity.dat.gz