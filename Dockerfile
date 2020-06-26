FROM nginx
RUN apt-get update && \
    apt-get install -y ruby && \
    rm -rf /var/lib/apt/lists/*

COPY nginx.ssl.conf nginx.http_only.conf /templates/
COPY bin/start /usr/sbin/start

RUN rm /etc/nginx/conf.d/default.conf && \
    chmod +x /usr/sbin/start && \
    sed -i 's/access_log .*/access_log \/dev\/stdout combined;/g' /etc/nginx/nginx.conf && \
    sed -i 's/access_log .*/error_log \/dev\/stderr info;/g' /etc/nginx/nginx.conf

EXPOSE 80 443
VOLUME /certs

CMD /usr/sbin/start