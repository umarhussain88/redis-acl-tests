# redis-acl-tests

docker-compose up -d

## Open Redis CLI Terminal
```bash
docker-compose exec -it redis redis-cli


ACL SETUSER fxuser on >fxpassword123
ACL SETUSER fxuser -@all ~fx:* +@read -@dangerous
ACL GETUSER fxuser
```

Then run the python test script

```bash
python3 app/redis_simple.py
```