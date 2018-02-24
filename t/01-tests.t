use Test::Nginx::Socket;
use Cwd qw(cwd);
use File::Copy;

plan tests => repeat_each() * (blocks() * 4);

my $pwd = cwd();

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';
$ENV{TEST_COVERAGE} ||= 0;
$ENV{TEST_NGINX_PORT} = server_port_for_client();
env_to_nginx("TEST_NGINX_PORT");

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;/usr/local/share/lua/5.1/?.lua;;";
    error_log logs/error.log debug;
    resolver $ENV{TEST_NGINX_RESOLVER};

    init_by_lua_block {
        if $ENV{TEST_COVERAGE} == 1 then
            jit.off()
            require("luacov.runner").init()
        end
    }
};

sub read_file {
    my $infile = shift;
    open my $in, $infile
        or die "cannot open $infile for reading: $!";
    my $cert = do { local $/; <$in> };
    close $in;
    $cert;
}

our $TestCertificate = read_file("t/cert/test.crt");
our $TestCertificateKey = read_file("t/cert/test.key");

our $SuccessResponse = read_file("t/responses/success_response.json");
our $RateExceededResponse = read_file("t/responses/rate_exceeded_response.json");

no_long_string();
run_tests();

__DATA__

=== TEST 1: Successful forward geocoding
--- main_config

--- http_config eval: $::HttpConfig
--- config
    location = /forward_geo_success {
        content_by_lua '
            ngx.log(ngx.DEBUG, "Starting forward geocoding success case")

            local geocoder = require "opencage.geocoder"

            local gc = geocoder.new({
                key = "1234",
                url = string.format("http://127.0.0.1:%d/mock", os.getenv("TEST_NGINX_PORT"))
            })

            local res, status, err = gc:geocode("Brandenburg Gate")

            if not res then
                ngx.say("failed to request: ", err)
            end

            ngx.say(res.total_results)

            if (res.total_results == 1 and #res.results == 1) then
                ngx.say(res.results[1].geometry.lat)
                ngx.say(res.results[1].geometry.lng)
                ngx.say(res.results[1].formatted)
            end

            ngx.log(ngx.DEBUG, "Closing client")
            gc:close()
            ngx.log(ngx.DEBUG, "Done")
        ';
    }

    location = /mock {
        if ($arg_key = 1234) {
            set $params "K";
        }

        if ($arg_no_annotations = 1) {
            set $params "${params}A";
        }

        if ($params = "KA") {
            rewrite '/mock' '/success_response.json';
        }
    }

--- user_files eval
">>> test.key
$::TestCertificateKey
>>> test.crt
$::TestCertificate
>>> success_response.json
$::SuccessResponse
>>> rate_exceeded_response.json
$::RateExceededResponse"
--- request
GET /forward_geo_success
--- response_body
1
52.5162767
13.3777025
Brandenburg Gate, Pariser Platz 1, 10117 Berlin, Germany
--- no_error_log
[error]
[warn]

=== TEST 2: Successful reverse geocoding
--- main_config

--- http_config eval: $::HttpConfig
--- config
    location = /reverse_geo_success {
        content_by_lua '
            ngx.log(ngx.DEBUG, "Starting reverse geocoding success case")

            local geocoder = require "opencage.geocoder"

            local gc = geocoder.new({
                key = "1234",
                url = string.format("http://127.0.0.1:%d/mock", os.getenv("TEST_NGINX_PORT"))
            })

            local res, status, err = gc:reverse_geocode(52.5162767, 13.3777025)

            if not res then
                ngx.say("failed to request: ", err)
            end

            ngx.say(res.total_results)

            if (res.total_results == 1 and #res.results == 1) then
                ngx.say(res.results[1].geometry.lat)
                ngx.say(res.results[1].geometry.lng)
                ngx.say(res.results[1].formatted)
            end

            ngx.log(ngx.DEBUG, "Closing client")
            gc:close()
            ngx.log(ngx.DEBUG, "Done")
        ';
    }

    location = /mock {
        if ($arg_key = 1234) {
            set $params "K";
        }

        if ($arg_no_annotations = 1) {
            set $params "${params}A";
        }

        if ($params = "KA") {
            rewrite '/mock' '/success_response.json';
        }
    }

--- user_files eval
">>> test.key
$::TestCertificateKey
>>> test.crt
$::TestCertificate
>>> success_response.json
$::SuccessResponse
>>> rate_exceeded_response.json
$::RateExceededResponse"
--- request
GET /reverse_geo_success
--- response_body
1
52.5162767
13.3777025
Brandenburg Gate, Pariser Platz 1, 10117 Berlin, Germany
--- no_error_log
[error]
[warn]


=== TEST 3: Rate exceeded test
--- main_config

--- http_config eval: $::HttpConfig
--- config
    location = /rate_exceeded {
        content_by_lua '
            ngx.log(ngx.DEBUG, "Starting rate exceeded case")

            local geocoder = require "opencage.geocoder"

            local gc = geocoder.new({
                key = "1234",
                url = string.format("http://127.0.0.1:%d/rate_exceeded_response", os.getenv("TEST_NGINX_PORT"))
            })

            local res, status, err = gc:reverse_geocode(52.5162767, 13.3777025)

            if not res then
                ngx.say("failed to request: ", err)
            else
                ngx.say(status)
            end

            ngx.log(ngx.DEBUG, "Closing client")
            gc:close()
            ngx.log(ngx.DEBUG, "Done")
        ';
    }

    error_page 429 /rate_exceeded_response.json;

    location = /rate_exceeded_response {
        return 429;
    }

--- user_files eval
">>> test.key
$::TestCertificateKey
>>> test.crt
$::TestCertificate
>>> success_response.json
$::SuccessResponse
>>> rate_exceeded_response.json
$::RateExceededResponse"
--- request
GET /rate_exceeded
--- response_body
429
--- no_error_log
[error]
[warn]


=== TEST 4: Custom parameters§
--- main_config

--- http_config eval: $::HttpConfig
--- config
    location = /custom_parameters {
        content_by_lua '
            ngx.log(ngx.DEBUG, "Starting rate exceeded case")

            local geocoder = require "opencage.geocoder"

            local gc = geocoder.new({
                key = "1234",
                url = string.format("http://127.0.0.1:%d/mock", os.getenv("TEST_NGINX_PORT"))
            })

            params = { abbrv = 1 }
            local res, status, err = gc:geocode("Brandenburg Gate", params)

            if not res then
                ngx.say("failed to request: ", err)
            else
                ngx.say("OK")
            end

            ngx.log(ngx.DEBUG, "Closing client")
            gc:close()
            ngx.log(ngx.DEBUG, "Done")
        ';
    }

    location /mock {
        if ($args = 'key=1234&abbrv=1&q=Brandenburg%20Gate&no_annotations=1') {
            rewrite '/mock' '/success_response.json';
        }
    }

--- user_files eval
">>> test.key
$::TestCertificateKey
>>> test.crt
$::TestCertificate
>>> success_response.json
$::SuccessResponse
>>> rate_exceeded_response.json
$::RateExceededResponse"
--- request
GET /custom_parameters
--- response_body
OK
--- no_error_log
[error]
[warn]
