# lua-resty-opencage-geocoder

This Lua module provides a simple client for the OpenCage forward/reverse geocoding API, to be used with [Openresty](https://openresty.org/en/).

# Installation

To install this module, run the following command using the Openresty package manager:

```bash
opm get nmdguerreiro/lua-resty-opencage-geocoder
```

# Sample usage

See the [sample nginx configuration file](nginx_sample.conf). It contains an example of how to make calls to the OpenCage API.
*Note:* You'll need to replace your API key in the configuration file before starting `nginx`. Once you've done that, you can run:

```bash
./nginx_sample.sh
```

After starting `nginx` you should be able to get some results:

```bash
$ curl localhost:8080


Result: {"timestamp":{"created_http":"Sat, 24 Feb 2018 19:21:44 GMT","created_unix":1519500104},"documentation":"https:\/\/geocoder.opencagedata.com\/api","thanks":"For using an OpenCage Data API","stay_informed":{"blog":"https:\/\/blog.opencagedata.com","twitter":"https:\/\/twitter.com\/opencagedata"},"results":[{"geometry":{"lng":13.3777025,"lat":52.5162767},"components":{"_type":"attraction","ISO_3166-1_alpha-2":"DE","suburb":"Mitte","state":"Berlin","road":"Pariser Platz","political_union":"European Union","house_number":"1","city":"Berlin","city_district":"Mitte","country":"Germany","postcode":"10117","country_code":"de","attraction":"Brandenburg Gate"},"confidence":9,"bounds":{"southwest":{"lng":13.37758,"lat":52.5161167},"northeast":{"lng":13.377825,"lat":52.5164327}},"formatted":"Brandenburg Gate, Pariser Platz 1, 10117 Berlin, Germany"},{"geometry":{"lng":-91.554716,"lat":34.515457},"components":{"_type":"road","state":"Arkansas","town":"Stuttgart","state_code":"AR","county":"Arkansas County","postcode":"72160","country":"United States of America","road":"Brandenburg Gate","country_code":"us","ISO_3166-1_alpha-2":"US"},"confidence":9,"bounds":{"southwest":{"lng":-91.5575726,"lat":34.515457},"northeast":{"lng":-91.554716,"lat":34.5155269}},"formatted":"Brandenburg Gate, Stuttgart, AR 72160, United States of America"}],"licenses":[{"url":"http:\/\/creativecommons.org\/licenses\/by-sa\/3.0\/","name":"CC-BY-SA"},{"url":"http:\/\/opendatacommons.org\/licenses\/odbl\/summary\/","name":"ODbL"}],"total_results":2,"rate":{"limit":2500,"reset":1519516800,"remaining":2481},"status":{"message":"OK","code":200}}
```

# Forward geocoding

To perform a forward geocoding request, all you need to do is instantiate the client and make the `geocode` call as is shown below:

```lua
local geocoder = require "opencage.geocoder"

local gc = geocoder.new({
  key = "REPLACE WITH YOUR KEY"
})

local res, status, err = gc:geocode("Brandenburg Gate")

gc.close()

```

Remember to close the client, so any underlying connections can be closed when you're done.

# Reverse geocoding

Similarly, to issue a reverse geocoding request, all you need to do is instantiate the client and make the `reverse_geocode` call as is shown below:

```lua
local geocoder = require "opencage.geocoder"

local lat, long = 52.5162767, 13.3777025

local gc = geocoder.new({
  key = "REPLACE WITH YOUR KEY"
})

local res, status, err = gc:reverse_geocode(lat, long)

gc.close()
```

Again, remember to close the client, so any underlying connections can be closed when you're done.

# Error handling

Calls to `geocode` and `reverse_geocode` return three values:
* The table that represents the JSON returned by the OpenCage API.
* A status code
* An error message, if applicable

For convenience, the status codes are available on the client object itself and are defined as per below (and in-line with the [API guide](https://geocoder.opencagedata.com/api#codes)):

```lua
gc.status_ok = 200
gc.status_invalid_request = 400
gc.status_quota_exceeded = 402
gc.status_invalid_key = 403
gc.status_timeout = 408
gc.status_request_too_long = 410
gc.status_rate_exceeded = 429
gc.status_internal_server_error = 503
```

So, you can handle errors like so:
```lua
local res, status, err = gc:geocode("Brandenburg Gate", params)

if (status = gc.status_invalid_key) then
    ngx.log(ngx.ERR, "It seems we forgot to set our API key correctly :-)")
end
```

# Parameters

You can supply any additional parameters to help improve your results, as is described in the [API guide](https://geocoder.opencagedata.com/api#forward-opt). For example:
```lua
local geocoder = require "opencage.geocoder"

local gc = geocoder.new({
  key = "REPLACE WITH YOUR KEY"
})

params = { abbrv = 1 }
local res, status, err = gc:geocode("Brandenburg Gate", params)

gc.close()
```

# Connection settings

This module depends on [lua-resty-http](), which enables you to configure connection and request timeouts.
To set the timeout, use the `timeout` parameter:

```lua

local gc = geocoder.new({
  key = "REPLACE WITH YOUR KEY",
  timeout = 5000, -- maximum timeout in milliseconds
})
```

# Licence
MIT
