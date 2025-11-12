import redis
#ACL SETUSER fxuser -@all "~fx:*" +@read -@dangerous works
r = redis.Redis(
            host='localhost',
            port=6379,
            username='fxuser',
            password='fxpassword123',
            decode_responses=True


        )

#simple get
value = r.get('fx:rate:USD:EUR')
print(f"USD to EUR Rate -- ", value )


# Test connection and get FX rates
rates = r.hscan('fx:rates', match='*:AUD', count=10)
print(f"Filtered Rates -- ", rates )

non_filtered_rates = r.hscan('fx:rates')
print(f"Filtered Rates -- ", non_filtered_rates)



