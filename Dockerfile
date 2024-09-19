FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
ARG BUILD_DATE
ARG VERSION
ARG ZOTERO_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=Zotero

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/zotero-icon.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    chromium \
    chromium-l10n \
    lbzip2 \
    libdbus-glib-1-2 \
    tint2 && \
  echo "**** install zotero ****" && \
  mkdir /opt/zotero && \
  if [ -z ${ZOTERO_VERSION+x} ]; then \
    ZOTERO_VERSION=$(curl -sL https://www.zotero.org/download/ \
      |awk -F'linux-x86_64' '/linux-x86_64/ {print $2}' \
      | awk -F'"' '{print $3}'); \
  fi && \
  curl -o \
    /tmp/zotero.tar.bz2 -L \
    "https://download.zotero.org/client/release/${ZOTERO_VERSION}/Zotero-${ZOTERO_VERSION}_linux-x86_64.tar.bz2" && \
  tar xf \
    /tmp/zotero.tar.bz2 -C \
    /opt/zotero/ --strip-components=1 && \
  ln -s \
    /opt/zotero/zotero \
    /usr/bin/zotero && \
  echo "**** OS Tweaks ****" && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-real && \
  sed -i \
    's/NLMC/NLIMC/g' \
    /etc/xdg/openbox/rc.xml && \
  sed -i \
    -e "s@^Icon=.*@Icon=/opt/zotero/icons/icon64.png@" \
    -e "s@^Exec=.*@Exec=/opt/zotero/zotero -url %U@" \
    /opt/zotero/zotero.desktop && \
  cp \
    /opt/zotero/zotero.desktop \
    /usr/share/applications/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
