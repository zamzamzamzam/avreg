FROM debian:stretch

ENV MEDIADIR=/avreg_media
ENV DBDIR=/avreg_db

RUN mkdir $MEDIADIR && ln -s $MEDIADIR /var/spool/avreg

VOLUME $DBDIR $MEDIADIR

# add avreg repository to application sources
RUN echo "deb http://avreg.net/repos/6.3-html5/debian/ stretch main contrib non-free" >> /etc/apt/sources.list

# remove policy file to allow start services while apt-get install
RUN rm -rf /usr/sbin/policy-rc.d

# prepare answers to install mysql
RUN echo "mysql-server mysql-server/root_password password 12345" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password 12345" | debconf-set-selections

# install avreg and remove any pid ghosts of it's service by stopping the service
RUN DEBIAN_FRONTEND="noninteractive" \
	apt-get update && apt-get install -y avreg-server-mysql \
	&& service avreg stop

# entry point will start mysql, apache2, and avreg services and stop them as well on demand
ADD entry_point.sh /
CMD ["/entry_point.sh"]

EXPOSE 80

