FROM kong:0.10.1
MAINTAINER Habor Huang, haborhuang@whispir.cc

ENV KONG_VERSION 0.10.1
ENV KONG_DATABASE cassandra
ENV KONG_LUA_PACKAGE_PATH /kong-plugins/?.lua;;
ENV KONG_CUSTOM_PLUGINS whispir-token-auth

ADD kong/ /kong-plugins/kong/
ADD run.sh /

RUN chmod +x run.sh

# Clear entrypoint of base image
ENTRYPOINT []
CMD ["/run.sh"]

EXPOSE 8000 8443 8001 7946