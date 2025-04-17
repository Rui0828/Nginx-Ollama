FROM openresty/openresty:alpine

# Remove default configuration
RUN rm -f /etc/nginx/conf.d/default.conf