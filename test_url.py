import urllib.parse
url = "redis://:pas%21%2B@redis:6379/1"
p = urllib.parse.urlparse(url)
print("netloc:", p.netloc)
print("hostname:", p.hostname)
try:
    print("port:", p.port)
except Exception as e:
    print("port error:", repr(e))
    
url2 = "redis://:pas!+@redis:6379/1"
p2 = urllib.parse.urlparse(url2)
try:
    print("port2:", p2.port)
except Exception as e:
    print("port error2:", repr(e))
