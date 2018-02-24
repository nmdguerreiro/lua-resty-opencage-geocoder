local http = require "resty.http"
local cjson = require "cjson"

local _M = {
    _VERSION = '0.1',
}

local mt = { __index = _M }

function _M._result(self, res, err)
    if not res then
        ngx.log(ngx.ERR, "Error while calling Opencage: " .. err)
        return nil, self.status_unexpected_error, err
    else
        local decoded = cjson.decode(res.body)
        return decoded, decoded.status.code, err
    end
end

-- Builds a new client.
-- @param options a table with two entries: 'key' as the API key and 'url' if you'd like to use a custom URL
function _M.new(options)
    local params = {
        httpc = http.new(),
        key = options.key,
        url = options.url or "https://api.opencagedata.com/geocode/v1/json",
        ssl_verify = false
    }

    -- set error code aliases
    options.status_unexpected_error = -1
    options.status_ok = 200
    options.status_invalid_request = 400
    options.status_quota_exceeded = 402
    options.status_invalid_key = 403
    options.status_timeout = 408
    options.status_request_too_long = 410
    options.status_rate_exceeded = 429
    options.status_internal_server_error = 503

    return setmetatable(params, mt)
end

-- Closes the client
function _M.close(self)
    return self.httpc:close()
end

-- Reverse geocodes a position (i.e. converts a latitude/longitude to a set of identifiers and codes that represent that position).
-- @param lat latitude
-- @param lng longitude
-- @return a tuple with 3 elements: the JSON response as a table if successful, the status code and an optional error message.
function _M.reverse_geocode(self, lat, lng, params)
    local query = { key = self.key; q = lat .. "," .. lng; no_annotations="1" }

    if params then
        for k,v in pairs(params) do query[k] = v end
    end

    local res, err = self.httpc:request_uri(self.url, {
        method = "GET",
        query = query,
        ssl_verify = false
    })

    return self:_result(res, err)
end

-- Forward geocodes an address (i.e. converts a textual address to a set of positions and returns information about those positions).
-- @param address place or address to lookup (e.g. Branderburg Gate)
-- @return a tuple with 3 elements: the JSON response as a table if successful, the status code and an optional error message.
function _M.geocode(self, address, params)
    local query = { key = self.key; q = address; no_annotations="1" }

    if params then
        for k,v in pairs(params) do query[k] = v end
    end

    local res, err = self.httpc:request_uri(self.url, {
        method = "GET",
        query = query,
        ssl_verify = false
    })

    return self:_result(res, err)
end

return _M