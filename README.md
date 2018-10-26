# Based on webdevops/php-nginx:alpine-php7
##### Automatic Build
- Add extra useful extensions on Webdevops's php-nginx:alpine-php7
- Added extensions
    - Nginx
        - nginx-mod-http-echo
        - nginx-mod-http-geoip
        - nginx-mod-http-lua
    - PHP
        - v8js
        - phalcon
        - igbinary
        - lzf
        - redis (with enable-redis-igbinary [YES] --enable-redis-lzf [YES])

