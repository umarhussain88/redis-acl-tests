import redis
## Steps
# ACL SETUSER fxuser on >fxpassword123
#ACL SETUSER fxuser -@all "~fx:*" +@read -@dangerous works

r = redis.Redis(
            host='localhost',
            port=6379,
            username='fxuser',
            password='fxpassword123',
            decode_responses=True


        )

# Test connection and get FX rates
rates = r.hscan('fx:rates', match='*:AUD', count=10)
print(f"Filtered Rates -- ", rates )

non_filtered_rates = r.hscan('fx:rates')
print(f"Filtered Rates -- ", non_filtered_rates)



