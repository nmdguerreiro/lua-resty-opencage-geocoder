# lua-resty-opencage-geocoder

This Lua module provides a simple client for the OpenCage forward/reverse geocoding API, to be used with [Openresty](https://openresty.org/en/).

# Installation

To install this module, run the following command using the Openresty package manager:

```
opm get nmdguerreiro/lua-resty-opencage-geocoder
```

# Sample usage

See the [sample nginx configuration file](nginx_sample.conf). It contains an example of how to make calls to the OpenCage API.
*Note:* You'll need to replace your API key in the configuration file before starting `nginx`.

After restaring `nginx` you should be able to get results:

```
$ curl localhost:8080


Result: {"timestamp":{"created_http":"Sat, 24 Feb 2018 19:21:44 GMT","created_unix":1519500104},"documentation":"https:\/\/geocoder.opencagedata.com\/api","thanks":"For using an OpenCage Data API","stay_informed":{"blog":"https:\/\/blog.opencagedata.com","twitter":"https:\/\/twitter.com\/opencagedata"},"results":[{"geometry":{"lng":13.3777025,"lat":52.5162767},"components":{"_type":"attraction","ISO_3166-1_alpha-2":"DE","suburb":"Mitte","state":"Berlin","road":"Pariser Platz","political_union":"European Union","house_number":"1","city":"Berlin","city_district":"Mitte","country":"Germany","postcode":"10117","country_code":"de","attraction":"Brandenburg Gate"},"confidence":9,"bounds":{"southwest":{"lng":13.37758,"lat":52.5161167},"northeast":{"lng":13.377825,"lat":52.5164327}},"formatted":"Brandenburg Gate, Pariser Platz 1, 10117 Berlin, Germany"},{"geometry":{"lng":-91.554716,"lat":34.515457},"components":{"_type":"road","state":"Arkansas","town":"Stuttgart","state_code":"AR","county":"Arkansas County","postcode":"72160","country":"United States of America","road":"Brandenburg Gate","country_code":"us","ISO_3166-1_alpha-2":"US"},"confidence":9,"bounds":{"southwest":{"lng":-91.5575726,"lat":34.515457},"northeast":{"lng":-91.554716,"lat":34.5155269}},"formatted":"Brandenburg Gate, Stuttgart, AR 72160, United States of America"}],"licenses":[{"url":"http:\/\/creativecommons.org\/licenses\/by-sa\/3.0\/","name":"CC-BY-SA"},{"url":"http:\/\/opendatacommons.org\/licenses\/odbl\/summary\/","name":"ODbL"}],"total_results":2,"rate":{"limit":2500,"reset":1519516800,"remaining":2481},"status":{"message":"OK","code":200}}
```

# Parameters

# Licence

MIT
