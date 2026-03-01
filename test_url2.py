import urllib.parse
urls = [
    "redis://:%21%2B",
    "redis://redis:%21%2B",
    "redis://:%21%2B@redis",
]
for url in urls:
    p = urllib.parse.urlparse(url)
    try:
        print(url, "-> port:", p.port)
    except Exception as e:
        print(url, "-> ERROR:", str(e))
