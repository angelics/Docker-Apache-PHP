FROM phusion/baseimage:focal-1.2.0
MAINTAINER angelics

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV LC_ALL          C.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8
ENV TERM xterm

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Define working directory.
WORKDIR /tmp

# Copy files
COPY helpers/* /usr/local/bin/

RUN \
	# Configure user nobody to match unRAID's settings
	usermod -u 99 nobody && \
	usermod -g 100 nobody && \
	usermod -d /home nobody && \
	chown -R nobody:users /home && \
	add-pkg \
		# Install basic compilation tools and dev libraries
		make \
		gcc \
		iasl \
		lzma-dev \
		mtools \
		perl \
		python \
        subversion \
		uuid-dev \
		liblzma-dev \
		mtools \
		# Install CGI Perl dependencies
		liburi-perl \
		libfcgi-perl \
		libconfig-inifiles-perl \
		libipc-system-simple-perl \
		libsub-override-perl \
		libcgi-pm-perl \
		# Install Git tools
		git \
		# Install Apache 2 with fast CGI and PHP5 module
		libapache2-mod-fcgid \
		libapache2-mod-php \
		apache2 \
		# Install JSON library Perl
		libjson-perl \
		libjson-any-perl \
		libjson-xs-perl \
		# Install extra packages to allow to build ISO and EFI binary
		binutils-dev \
		genisoimage \
		syslinux \
		isolinux \
		# wget
		wget \
		&& \
	a2enmod fcgid php7.4 && \
	service apache2 restart && \
	# Update apache configuration with this one
	mv /etc/apache2/sites-available/000-default.conf /etc/apache2/000-default.conf && \
	rm /etc/apache2/sites-available/* && \
	rm /etc/apache2/apache2.conf && \
	ln -s /config/proxy-config.conf /etc/apache2/sites-available/000-default.conf && \
	ln -s /var/log/apache2 /logs && \
	rm -rf /tmp/* /tmp/.[!.]*

# Copy files
COPY ipxe /

RUN \
	# Manually set the apache environment variables in order to get apache to work immediately.
	echo www-data > /etc/container_environment/APACHE_RUN_USER && \
	echo www-data > /etc/container_environment/APACHE_RUN_GROUP && \
	echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR && \
	echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR && \
	echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE && \
	echo /var/run/apache2 > /etc/container_environment/APACHE_RUN_DIR && \
	# Prepare iPXE directory
	ln -s /var/cache/ipxe-build /cache && \
	mkdir -p /var/cache/ipxe-build  && \
	mkdir -p /var/run/ipxe-build  && \
	mkdir -p /var/tmp/ipxe-build && \
	touch /var/run/ipxe-build/ipxe-build-cache.lock && \
	# Prepare the git buildweb repository
	mkdir -p /var/www && \
	# Prepare config folder
	mkdir -p /config && \
	ln -s /var/tmp/ipxe /ipxe && \
	ln -s /var/www/ipxe-buildweb /ipxe-buildweb && \
	rm -rf /tmp/* /tmp/.[!.]*

# Expose Ports
EXPOSE 80

# The www directory and proxy config location
VOLUME ["/logs","/ipxe", "/ipxe-buildweb", "/cache"]