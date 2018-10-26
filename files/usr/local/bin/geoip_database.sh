#!/usr/bin/env bash

[ -d /usr/share/GeoIP ] && mkdir /usr/share/GeoIP
cd /usr/share/GeoIP

wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz -O GeoIP.dat.gz
gzip -df GeoIP.dat.gz

wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz -O GeoLiteCity.dat.gz
gzip -df GeoLiteCity.dat.gz
