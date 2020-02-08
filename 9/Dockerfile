ARG IMAGE_TAG_POSTGRES=9

FROM postgres:${IMAGE_TAG_POSTGRES}

LABEL maintainer=gregor@plavcak.net
LABEL git.url=https://github.com/plavc/postgres

RUN mkdir /docker-entrypoint-patches.d \
    && mkdir /backup

COPY docker-entrypoint-ext.sh /usr/local/bin/
COPY docker-utils-backup.sh /usr/local/bin/

RUN ln -s usr/local/bin/docker-entrypoint-ext.sh / \
    && ln -s usr/local/bin/docker-utils-backup.sh /

ENTRYPOINT ["/docker-entrypoint-ext.sh"]

VOLUME /backup

EXPOSE 5432
CMD ["postgres"]