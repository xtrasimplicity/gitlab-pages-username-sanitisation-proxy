FROM nginx
RUN apt-get update && \
    apt-get install -y ruby && \
    rm -rf /var/lib/apt/lists/*


COPY nginx.conf /etc/nginx/conf.d/proxy.conf
COPY bin/start /usr/sbin/start

RUN rm /etc/nginx/conf.d/default.conf && \
    chmod +x /usr/sbin/start

EXPOSE 80 443
CMD /usr/sbin/start