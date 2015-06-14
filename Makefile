php_version=5.6.9
php_zip_basename=php-$(php_version)-Win32-VC11-x86
php_zip=$(php_zip_basename).zip
php_zip_url=http://installer-bin.streambox.com/$(php_zip)
curl_agent='Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.71 Safari/537.17'
RM=rm -f
7Z=7z

composer: composer.phar
	ln --force -s composer.cmd $@

composer.phar: php
	sed -i.bak -e 's/^;extension=php_openssl.dll/extension=php_openssl.dll/' \
		-e 's/^; extension_dir = "ext"/extension_dir = ext/' php/php.ini
	curl -s http://getcomposer.org/installer | PATH=php:/usr/bin php -c php

version: php/
	PATH=php php.exe --version

php: $(php_zip)
	$(7Z) x -y -o$@ $(php_zip) >/dev/null
	chmod -R +x php
	cp php/php.ini-development php/php.ini

diff: php/php.ini
	-diff -uw php/php.ini-development php/php.ini

php/php.ini: php
	cp php/php.ini-development php/php.ini

$(php_zip):
	choco install vcredist2013 -yes -forcex86
	curl -A "$(curl_agent)" -O $(php_zip_url)

veryclean:
	$(MAKE) clean
	$(RM) composer.phar

clean:
	$(RM) composer
	$(RM) -r php
