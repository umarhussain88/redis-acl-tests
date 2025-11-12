FROM redis:7-alpine

# Create redis configuration directory and init directory
RUN mkdir -p /usr/local/etc/redis /docker-entrypoint-initdb.d

# Create Redis configuration file
RUN echo "port 6379" > /usr/local/etc/redis/redis.conf && \
    echo "bind 0.0.0.0" >> /usr/local/etc/redis/redis.conf && \
    echo "protected-mode no" >> /usr/local/etc/redis/redis.conf && \
    echo "databases 1" >> /usr/local/etc/redis/redis.conf && \
    echo "save 900 1" >> /usr/local/etc/redis/redis.conf && \
    echo "save 300 10" >> /usr/local/etc/redis/redis.conf && \
    echo "save 60 10000" >> /usr/local/etc/redis/redis.conf

# Copy files into container
COPY fx_rates.csv /tmp/fx_rates.csv
COPY acl_permissions.txt /tmp/acl_permissions.txt

# Create initialization script
RUN printf '#!/bin/sh\n\
PERMS=$(cat /tmp/acl_permissions.txt | tr "\n" " ")\n\
redis-cli ACL SETUSER fxuser on >fxpassword123 ~* &* $PERMS\n\
tail -n +2 /tmp/fx_rates.csv | while IFS=, read -r pair rate updated; do\n\
  redis-cli HSET fx:rates "$pair" "$rate"\n\
  redis-cli HSET fx:last_updated "$pair" "$updated"\n\
done\n\
redis-cli SADD fx:currencies USD EUR GBP JPY CHF CAD AUD\n\
redis-cli SET fx:data_loaded "$(date)"\n' > /docker-entrypoint-initdb.d/init.sh && \
    chmod +x /docker-entrypoint-initdb.d/init.sh

# Create startup script
RUN printf '#!/bin/sh\n\
redis-server /usr/local/etc/redis/redis.conf &\n\
sleep 5\n\
/docker-entrypoint-initdb.d/init.sh\n\
wait\n' > /start-redis.sh && \
    chmod +x /start-redis.sh

EXPOSE 6379

CMD ["/start-redis.sh"]