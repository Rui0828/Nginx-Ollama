FROM openresty/openresty:alpine

# Remove default configuration
RUN mkdir -p /var/log/nginx/
RUN rm -f /etc/nginx/conf.d/default.conf
