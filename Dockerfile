FROM ubuntu:16.04

RUN apt-get update -q \
  && apt-get install -yq \
     nginx-extras \
     apache2-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

VOLUME /media
EXPOSE 8000
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY file-range.lua /etc/nginx/file-range.lua
RUN rm /etc/nginx/sites-enabled/*

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh
CMD /entrypoint.sh && nginx -g "daemon off;"
