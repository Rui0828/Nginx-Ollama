FROM openresty/openresty:alpine

RUN rm -f /etc/nginx/conf.d/default.conf

COPY conf.d /etc/nginx/conf.d
COPY ollama /etc/nginx/ollama