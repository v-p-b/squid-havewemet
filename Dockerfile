FROM debian:bullseye-slim
RUN apt-get update
RUN apt-get install -y build-essential openssl wget libssl-dev python3
RUN wget http://www.squid-cache.org/Versions/v5/squid-5.6.tar.gz
RUN tar -xzvf squid-5.6.tar.gz
WORKDIR squid-5.6
RUN ./configure --with-openssl
RUN make
RUN make install
RUN mkdir -p /usr/local/squid/var/logs
RUN chown nobody /usr/local/squid/var/logs
RUN mkdir -p /usr/local/squid/etc/ssl
RUN openssl req -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=havewemet.local" -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /usr/local/squid/etc/ssl/squid_CA.pem -keyout /usr/local/squid/etc/ssl/squid_CA.key

COPY docker/squid.conf /usr/local/squid/etc/squid.conf
COPY havewemet /opt/havewemet/havewemet
RUN chmod o+x /opt/havewemet/havewemet
COPY havewemet.html /usr/local/squid/share/errors/templates/havewemet.html

EXPOSE 3128/tcp

CMD ["/usr/local/squid/sbin/squid","-NCd1"]
