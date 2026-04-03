# syntax=docker/dockerfile:1
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Kismet APT repository (Debian Bookworm)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        iproute2 \
        iw \
        jq \
        wireless-tools \
    && curl -fsSL https://www.kismetwireless.net/repos/kismet-release.gpg.key \
        | gpg --dearmor -o /etc/apt/trusted.gpg.d/kismet-release.gpg \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/kismet-release.gpg] https://www.kismetwireless.net/repos/apt/release/bookworm bookworm main" \
        > /etc/apt/sources.list.d/kismet.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends kismet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
