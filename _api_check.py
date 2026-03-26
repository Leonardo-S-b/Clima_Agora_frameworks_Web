import json
import urllib.parse
import urllib.request

q = 'Sao Paulo'
url = 'https://geocoding-api.open-meteo.com/v1/search?' + urllib.parse.urlencode({
    'name': q,
    'count': 3,
    'language': 'pt',
    'format': 'json',
})
print('URL:', url)
with urllib.request.urlopen(url, timeout=10) as r:
    data = r.read().decode('utf-8')
print('HTTP OK, bytes:', len(data))
obj = json.loads(data)
results = obj.get('results') or []
print('results:', len(results))
if results:
    first = results[0]
    print('first:', first.get('name'), first.get('admin1'), first.get('country'))
