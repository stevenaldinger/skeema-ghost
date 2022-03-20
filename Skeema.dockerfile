FROM ubuntu:22.04

ENV \
  SKEEMA_VERSION="1.7.0"

# install skeema
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && curl -LO "https://github.com/skeema/skeema/releases/download/v${SKEEMA_VERSION}/skeema_${SKEEMA_VERSION}_linux_$(dpkg --print-architecture).tar.gz" \
 && tar -xzvf "skeema_${SKEEMA_VERSION}_linux_$(dpkg --print-architecture).tar.gz" skeema \
 && mv skeema /usr/local/bin/ \
 && rm "skeema_${SKEEMA_VERSION}_linux_$(dpkg --print-architecture).tar.gz"

# install gh-ost
RUN curl -Lo gh-ost.tar.gz https://github.com/github/gh-ost/releases/download/v1.1.4/gh-ost-binary-linux-20220225143506.tar.gz \
 && tar -xzvf ./gh-ost.tar.gz \
 && mv ./gh-ost /usr/local/bin/ \
 && rm -rf ./gh-ost.tar.gz