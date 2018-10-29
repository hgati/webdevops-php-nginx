#################
## BUILD STAGE ##
#################
FROM alexmasterov/alpine-libv8:6.9 as v8build
# Compress libv8 and save for later
RUN tar cvzf /tmp/libv8.tar.gz -C $V8_DIR .

#################
## FINAL STAGE ##
#################
FROM webdevops/php-nginx:alpine-php7
LABEL maintainer="hgati <cobays@gmail.com>"
ARG PHALCON_VERSION=3.4.1

# copy configuration files
COPY files /

# v8js files
COPY --from=v8build /tmp/libv8.tar.gz /tmp/libv8.tar.gz

RUN cd /tmp \
	# nginx 3rd party modules
	&& apk-install nginx-mod-http-echo nginx-mod-http-geoip nginx-mod-http-lua \
	&& sed -i '1 i\load_module "modules/ndk_http_module.so";' /etc/nginx/modules/http_lua.conf \
	# GeoIP 데이터베이스 다운로드
	&& chmod -R 755 /usr/local/bin \
	&& geoip_database.sh \
	#&& apk --no-cache add --virtual .build-deps alpine-sdk php7-dev \
	&& apk add -u --no-cache --virtual .build-deps $PHPIZE_DEPS zlib-dev g++ make php7-dev re2c \
	# v8js extension
	&& export V8_DIR=/usr/local/v8 \
	&& mkdir -p $V8_DIR \
	&& tar xzvf /tmp/libv8.tar.gz -C $V8_DIR \
	&& echo $V8_DIR | pecl install v8js \
	&& echo "extension=v8js.so" > /etc/php7/conf.d/v8js.ini \
	# phalcon extension
	&& git clone --depth=1 --branch=v$PHALCON_VERSION "git://github.com/phalcon/cphalcon.git" \
	&& cd cphalcon/build \
	&& ./install \
	&& echo "extension=phalcon.so" > /etc/php7/conf.d/phalcon.ini \
	# igbinary extension, redis.so에서 이용하려면 우선순위가 먼저 로드되어야 에러안남
	&& pecl install igbinary \
	&& echo "extension=igbinary.so" > /etc/php7/conf.d/19_igbinary.ini \
	# lzf extension, redis.so에서 이용하려면 우선순위가 먼저 로드되어야 에러안남
	&& printf "\n" | pecl install lzf \
	&& echo "extension=lzf.so" > /etc/php7/conf.d/19_lzf.ini \
	# php-redis extension, enable-redis-igbinary [YES] --enable-redis-lzf [YES]
	# 기존에 이미 설치되어있어서 먼저 삭제후, 설치해야함. 기존에 igbinary, lzf함께 활성화해서 설치했는지 불투명하므로 일단 삭제.
	&& pecl uninstall redis \
	&& yes "yes" | pecl install redis \
	&& echo "extension=redis.so" > /etc/php7/conf.d/20_redis.ini \
	# 동적모듈추가가능하게 (webdevops가 nginx.conf 상단부분에 대한 수정지원이 불가하여 편법으로 해결함)
    && sed -i '1 i\include modules.conf;' /opt/docker/etc/nginx/nginx.conf \
	# clean
	&& chmod -R 755 /usr/lib/php7/modules \
	&& rm -rf /tmp/* \
	&& apk del .build-deps
