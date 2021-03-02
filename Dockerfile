FROM centos:7
LABEL maintainer="sergey@ortoped.org.ru"

ENV RC_INSTALLER    RhodeCode-installer-linux-build20210208_0800
ENV RC_CHECKSUM     a39e6019cd81a4178c5f0f157e1cfafb2bb9e8700fd2b656f6f2e7b5983cda2f

# Create the RhodeCode user
RUN useradd rhodecode -u 1000 -s /sbin/nologin				\
		&& mkdir -m 0755 -p /opt/rhodecode /data			\
		&& chown rhodecode:rhodecode /opt/rhodecode /data	\
		&& yum install -y bzip2 postgresql					\
		&& curl -so /usr/local/bin/crudini https://raw.githubusercontent.com/pixelb/crudini/0.9/crudini \
		&& chmod +x /usr/local/bin/crudini

USER rhodecode
WORKDIR /home/rhodecode

# Install RhodeCode Control
RUN curl -so $RC_INSTALLER https://dls-eu.rhodecode.com/dls/NjY3MjY1NzQ3MjZjNDA2MjY1Njc2MjYzNzI3MTJlNjI2NTc0MmU2NTY4/rhodecode-control/latest-linux-ee \
		&& echo "$RC_CHECKSUM *$RC_INSTALLER" |  sha256sum -c -	\
		&& chmod 755 $RC_INSTALLER								\
		&& ./$RC_INSTALLER --accept-license						\
		&& rm $RC_INSTALLER

# Add additional tools
COPY files .
# RUN chmod 755 install.sh
# RUN chmod 755 start.sh

ENV RC_VERSION 4.24.1
RUN RC_APP=VCSServer RC_DB=sqlite ./install.sh
RUN RC_APP=Community RC_DB=sqlite ./install.sh

CMD ["./start.sh"]