## base
FROM redis AS base

ENV DEBIAN_FRONTEND=noninteractive


## builder
FROM base AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext-base \
    && rm -rf /var/lib/apt/lists/*


## runner
FROM base AS runner
WORKDIR /opt/sentinel


COPY --from=builder /usr/bin/envsubst /usr/bin/envsubst
COPY sentinel.conf.template /opt/sentinel/sentinel.conf.template
COPY docker-entrypoint.sh /opt/sentinel/docker-entrypoint.sh

RUN chmod +x /opt/sentinel/docker-entrypoint.sh \
    && mkdir -p /etc/redis \
    && chown redis:redis /etc/redis

USER redis

ENTRYPOINT ["/opt/sentinel/docker-entrypoint.sh"]