FROM nginx

RUN mkdir -p /var/log/nextcloud/
RUN ln -sf /dev/stdout /var/log/nextcloud/nextcloud-access.log
RUN ln -sf /dev/stderr /var/log/nextcloud/nextcloud-error.log