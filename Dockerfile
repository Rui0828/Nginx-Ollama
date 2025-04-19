FROM openresty/openresty:alpine

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    echo "Asia/Taipei" > /etc/timezone

# Remove default configuration
RUN mkdir -p /var/log/nginx/
RUN rm -f /etc/nginx/conf.d/default.conf

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
