import re
import urllib.parse

raw_redis_url = 'redis://:viva-redis-pass@redis:6379/1'
redis_pass_raw = 'viva-redis-pass!+'
redis_pass_encoded = urllib.parse.quote(redis_pass_raw)

if '@' in raw_redis_url:
    redis_url = re.sub(r'redis://(.*?@)', f'redis://:{redis_pass_encoded}@', raw_redis_url)
else:
    redis_url = raw_redis_url.replace('redis://', f'redis://:{redis_pass_encoded}@')

print("URL:", redis_url)
