# lua-resty-ua-parser

This is the Lua implementation of [ua-parser](https://github.com/ua-parser) for [OpenResty](http://openresty.org/) / [ngx\_lua](https://github.com/openresty/lua-nginx-module).
The implementation uses the shared regex patterns and overrides from [regexes.yaml](https://github.com/ua-parser/uap-core/blob/master/regexes.yaml), but in JSON format due to the lack of lightweight YAML parsers.