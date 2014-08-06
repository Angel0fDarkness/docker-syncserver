# Use phusion/baseimage based on Ubuntu 14.04
FROM phusion/baseimage:0.9.12
MAINTAINER Tobias Rausch (angel0fdarkness)

# Use UTF-8 locale inside the container
RUN locale-gen en_US.UTF-8 && echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Disable SSH (currently not used)
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Install needed requirements for the Mozilla Syncserver
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes python-dev git-core python-virtualenv python-setuptools libpq-dev

# Install build environment
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes build-essential

# Install some Python dependencies
RUN easy_install psycopg2

# Install other tools.
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pwgen ca-certificates

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Map the start scripts to the container
ADD scripts /scripts
RUN chmod +x /scripts/start.sh
ADD config/syncserver.ini /home/ffsync/syncserver.ini

# Create link for runit to start the syncserver
RUN mkdir /etc/service/syncserver
RUN ln -s /scripts/start.sh /etc/service/syncserver/run

# Add a new user
RUN useradd --create-home ffsync
RUN chown -R ffsync:ffsync /home/ffsync

# Download & Build Mozilla Syncserver
WORKDIR /home/ffsync
RUN su ffsync -c 'git clone https://github.com/mozilla-services/syncserver'
WORKDIR /home/ffsync/syncserver
RUN su ffsync -c 'make build'

# Expose port 5000 and start the server
EXPOSE 5000

# Use the init system from baseimage
CMD ["/sbin/my_init"]
