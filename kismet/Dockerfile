# syntax=docker/dockerfile:1
# Supervisor injects BUILD_FROM per arch; default avoids empty FROM in static analysis.
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:bookworm
FROM ${BUILD_FROM}

ARG BUILD_VERSION="0.2.0"
ARG BUILD_ARCH

LABEL \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.type="addon" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.name="Kismet Sniffer" \
    io.hass.description="Kismet Wi-Fi (and optional BLE) capture; REST API port 2501."

# Kismet APT repository (Debian Bookworm)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        iproute2 \
        iw \
        jq \
        rfkill \
        wireless-tools \
    && curl -fsSL https://www.kismetwireless.net/repos/kismet-release.gpg.key \
        | gpg --dearmor -o /etc/apt/trusted.gpg.d/kismet-release.gpg \
    && echo "deb [signed-by=/etc/apt/trusted.gpg.d/kismet-release.gpg] https://www.kismetwireless.net/repos/apt/release/bookworm bookworm main" \
        > /etc/apt/sources.list.d/kismet.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        kismet-core \
        kismet-capture-linux-wifi \
        kismet-capture-linux-bluetooth \
        kismet-logtools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
